class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @artigo  = Article.publicados.friendly.find(params[:article_id])
    @comment = @artigo.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      Notification.notificar_admins_novo_comentario(@comment)
      Notification.notificar_resposta(@comment) if @comment.parent_id?
      redirect_to noticia_path(@artigo.slug, anchor: "secao-comentarios"),
                  flash: { comentario_pendente: true }
    else
      redirect_to noticia_path(@artigo.slug, anchor: "secao-comentarios"),
                  alert: @comment.errors.full_messages.join(", ")
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:conteudo, :parent_id)
  end
end
