class Usuario::SalvosController < Usuario::BaseController

  def index
    @pagy, @salvos = pagy(
      current_user.saved_articles.includes(article: [:category, :author]).order(created_at: :desc)
    )
  end

  def create
    artigo = Article.find(params[:article_id])
    current_user.saved_articles.find_or_create_by!(article: artigo)
    redirect_back_or_to noticia_path(artigo.slug), notice: "Artigo salvo."
  end

  def destroy
    salvo = current_user.saved_articles.find(params[:id])
    salvo.destroy
    redirect_back_or_to usuario_salvos_path, notice: "Artigo removido dos salvos."
  end
end
