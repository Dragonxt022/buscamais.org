class Admin::ArtigosController < Admin::BaseController

  before_action :carregar_artigo, only: [:show, :edit, :update, :destroy, :publicar, :arquivar, :destacar]

  def index
    scope = Article.includes(:author, :category).with_attached_imagem_capa_file.order(created_at: :desc)
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where(category_id: params[:categoria_id]) if params[:categoria_id].present?
    scope = scope.where("titulo LIKE ?", "%#{params[:q]}%") if params[:q].present?
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
    if @artigo.save
      attach_gallery_image
      processar_tags(@artigo)
      redirect_to admin_artigos_path, notice: "Artigo criado com sucesso."
    else
      @categorias = Category.ativas.order(:nome)
      @tags = Tag.order(:nome)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categorias = Category.ativas.order(:nome)
    @tags = Tag.order(:nome)
  end

  def update
    if @artigo.update(artigo_params)
      attach_gallery_image
      processar_tags(@artigo)
      redirect_to admin_artigos_path, notice: "Artigo atualizado."
    else
      @categorias = Category.ativas.order(:nome)
      @tags = Tag.order(:nome)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @artigo.destroy
    redirect_to admin_artigos_path, notice: "Artigo removido."
  end

  def bulk_destroy
    ids = Array(params[:ids]).map(&:to_i)
    count = Article.where(id: ids).destroy_all.size
    redirect_to admin_artigos_path, notice: "#{count} artigo(s) removido(s)."
  end

  def publicar
    @artigo.update!(status: :publicado)
    redirect_to admin_artigos_path, notice: "Artigo publicado."
  end

  def arquivar
    @artigo.update!(status: :arquivado)
    redirect_to admin_artigos_path, notice: "Artigo arquivado."
  end

  def destacar
    @artigo.update!(destaque: !@artigo.destaque)
    redirect_to admin_artigos_path, notice: "Destaque atualizado."
  end

  private

  def carregar_artigo
    @artigo = Article.find(params[:id])
  end

  def artigo_params
    params.require(:article).permit(:titulo, :resumo, :status,
                                    :destaque, :premium, :category_id, :agendado_em,
                                    :conteudo, :legenda_capa, categorias_extras_ids: [])
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
