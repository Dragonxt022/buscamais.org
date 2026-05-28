class Usuario::SalvosController < Usuario::BaseController

  def index
    @pagy, @salvos = pagy(
      current_user.saved_articles
                  .includes(article: [:category, :author, { imagem_capa_file_attachment: :blob }])
                  .order(created_at: :desc)
    )
  end

  def create
    artigo = Article.find(params[:article_id])
    unless current_user.pode_salvar_mais_artigos?
      limite = current_user.plano_permissao("salvar_materias_limite")
      redirect_back_or_to noticia_path(artigo.slug),
        flash: { upgrade_prompt: "Limite de #{limite} artigos salvos atingido. Faça upgrade para salvar sem limites." }
      return
    end
    current_user.saved_articles.find_or_create_by!(article: artigo)
    redirect_back_or_to noticia_path(artigo.slug), notice: "Artigo salvo."
  end

  def destroy
    salvo = current_user.saved_articles.find(params[:id])
    salvo.destroy
    redirect_back_or_to usuario_salvos_path, notice: "Artigo removido dos salvos."
  end
end
