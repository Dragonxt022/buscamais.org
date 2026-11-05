class Admin::FeedsController < Admin::BaseController
  before_action :carregar_feed, only: [ :edit, :update, :destroy, :sincronizar, :toggle_ativo ]

  def index
    @feeds = FeedSource.includes(:category, :author).order(created_at: :desc)
    @total_importados = Article.importados.count
    @ultima_sincronizacao = FeedSource.maximum(:ultima_sincronizacao_em)
    @pendencias_ia = Article.importados
                            .where(reescrita_status: [ nil, "desativada", "falhou" ])
                            .where.not(fonte_url: [ nil, "" ])
                            .where.not(status: Article.statuses["arquivado"])
                            .count
  end

  def new
    @feed = FeedSource.new(
      intervalo_minutos: 60,
      publicar_automaticamente: true,
      importar_imagem: true,
      creditar_fonte: true,
      reescrita_automatica: true,
      limite_por_sincronizacao: 10
    )
    carregar_opcoes
  end

  def create
    @feed = FeedSource.new(feed_params)
    @feed.author ||= current_user

    if @feed.save
      redirect_to admin_feeds_path, notice: "Feed cadastrado. A primeira sincronização acontece em até 1 minuto."
    else
      carregar_opcoes
      render :new, status: :unprocessable_entity
    end  end

  def edit
    carregar_opcoes
  end

  def update
    @feed.assign_attributes(feed_params)
    @feed.author ||= current_user

    if @feed.save
      redirect_to admin_feeds_path, notice: "Feed atualizado."
    else
      carregar_opcoes
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @feed.destroy
    redirect_to admin_feeds_path, notice: "Feed removido. As matérias já importadas foram mantidas."
  end

  def sincronizar
    FeedSyncJob.perform_later(@feed.id)
    redirect_to admin_feeds_path,
                notice: "#{@feed.nome}: sincronização iniciada. O resultado aparece na lista em instantes."
  rescue => e
    Rails.logger.error("[Admin::FeedsController] sincronizar ##{@feed.id}: #{e.class}: #{e.message}")
    redirect_to admin_feeds_path, alert: "Não foi possível iniciar a sincronização: #{e.message}"
  end

  def toggle_ativo
    @feed.update!(ativo: !@feed.ativo)
    redirect_to admin_feeds_path, notice: @feed.ativo? ? "Feed ativado." : "Feed pausado."
  end

  def reprocessar
    unless OllamaClient.new.configurado?
      redirect_to admin_feeds_path,
                  alert: "Configure o modelo do Ollama em Admin → Configurações → Reescrita com IA antes de reprocessar."
      return
    end

    limite = params[:limite].to_i
    limite = ReescritaArtigosJob::LIMITE_PADRAO if limite <= 0

    ReescritaArtigosJob.perform_later(
      feed_id: params[:feed_id].presence,
      limite: limite
    )

    redirect_to admin_feeds_path,
                notice: "Reprocessamento com IA iniciado. As matérias vão mudando de status conforme forem reescritas."
  rescue => e
    Rails.logger.error("[Admin::FeedsController] reprocessar: #{e.class}: #{e.message}")
    redirect_to admin_feeds_path, alert: "Não foi possível iniciar o reprocessamento: #{e.message}"
  end

  private

  def carregar_feed
    @feed = FeedSource.find(params[:id])
  end

  def carregar_opcoes
    @categorias = Category.ativas.order(:nome)
    @autores    = User.pode_publicar.order(:nome)
  end

  def feed_params
    params.require(:feed_source).permit(
      :nome, :url, :ativo, :intervalo_minutos, :publicar_automaticamente,
      :importar_imagem, :creditar_fonte, :reescrita_automatica,
      :limite_por_sincronizacao, :category_id, :author_id
    )
  end
end
