class Editor::ArtigosController < Editor::BaseController

  before_action :carregar_artigo, only: [:show, :edit, :update, :destroy, :publicar, :arquivar]

  def index
    scope = Article.includes(:author, :category)
                   .with_attached_imagem_capa_file
                   .where(author: current_user)
                   .order(created_at: :desc)
    scope = scope.where(status: params[:status]) if params[:status].present?
    @pagy, @artigos = pagy(scope)
    @categorias = Category.ativas.order(:nome)
  end

  def show; end

  def new
    @artigo = Article.new
    @categorias = Category.ativas.order(:nome)
    @tags = Tag.order(:nome)
  end

  def create
    @artigo = Article.new(artigo_params)
    @artigo.author = current_user
    @artigo.status = current_user.administrador? ? :rascunho : :aguardando_revisao if @artigo.status.blank?

    if @artigo.save
      attach_gallery_image
      processar_tags(@artigo)
      redirect_to editor_artigos_path, notice: "Artigo salvo com sucesso."
    else
      @categorias = Category.ativas.order(:nome)
      @tags = Tag.order(:nome)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @artigo, :update?
    @categorias = Category.ativas.order(:nome)
    @tags = Tag.order(:nome)
  end

  def update
    authorize @artigo, :update?
    if @artigo.update(artigo_params)
      attach_gallery_image
      processar_tags(@artigo)
      redirect_to editor_artigos_path, notice: "Artigo atualizado."
    else
      @categorias = Category.ativas.order(:nome)
      @tags = Tag.order(:nome)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @artigo, :destroy?
    @artigo.destroy
    redirect_to editor_artigos_path, notice: "Artigo removido."
  end

  def bulk_destroy
    ids = Array(params[:ids]).map(&:to_i)
    artigos = Article.where(id: ids, author: current_user)
    count = artigos.destroy_all.size
    redirect_to editor_artigos_path, notice: "#{count} artigo(s) removido(s)."
  end

  def publicar
    authorize @artigo, :publicar?
    @artigo.update!(status: :publicado)
    redirect_to editor_artigos_path, notice: "Artigo publicado."
  end

  def arquivar
    authorize @artigo, :arquivar?
    @artigo.update!(status: :arquivado)
    redirect_to editor_artigos_path, notice: "Artigo arquivado."
  end

  private

  def carregar_artigo
    @artigo = Article.find(params[:id])
  end

  def artigo_params
    params.require(:article).permit(:titulo, :resumo, :status,
                                    :premium, :category_id, :agendado_em,
                                    :conteudo)
  end

  def processar_tags(artigo)
    nomes_raw = params.dig(:article, :tag_names)
    return unless nomes_raw.is_a?(String)
    nomes = nomes_raw.split(",").map(&:strip).reject(&:empty?).uniq
    artigo.tags = nomes.map { |nome| Tag.find_or_create_by!(nome: nome) }
  rescue => e
    Rails.logger.error "[Tags] Erro: #{e.message}"
  end

  def attach_gallery_image
    sgid = params.dig(:article, :imagem_capa_sgid).presence
    return unless sgid
    blob = ActiveStorage::Blob.find_signed(sgid)
    @artigo.imagem_capa_file.attach(blob) if blob
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end
end
