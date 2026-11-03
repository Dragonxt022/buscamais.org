class Admin::FeedsController < Admin::BaseController
  before_action :carregar_feed, only: [ :edit, :update, :destroy, :sincronizar, :toggle_ativo ]

  def index
    @feeds = FeedSource.includes(:category, :author).order(created_at: :desc)
    @total_importados = Article.importados.count
    @ultima_sincronizacao = FeedSource.maximum(:ultima_sincronizacao_em)
  end

  def new
    @feed = FeedSource.new(
      intervalo_minutos: 60,
      publicar_automaticamente: true,
      importar_imagem: true,
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
    end
  end

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
    resultado = @feed.sincronizar!

    if resultado.sucesso?
      redirect_to admin_feeds_path, notice: "#{@feed.nome}: #{resultado.mensagem}"
    else
      redirect_to admin_feeds_path, alert: "#{@feed.nome}: #{resultado.mensagem}"
    end
  end

  def toggle_ativo
    @feed.update!(ativo: !@feed.ativo)
    redirect_to admin_feeds_path, notice: @feed.ativo? ? "Feed ativado." : "Feed pausado."
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
      :importar_imagem, :limite_por_sincronizacao, :category_id, :author_id
    )
  end
end
