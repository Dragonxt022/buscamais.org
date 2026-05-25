class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @artigo = Article.publicados.friendly.find(params[:article_id])
    @comment = @artigo.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to noticia_path(@artigo.slug), notice: "Comentário enviado! Será publicado após aprovação."
    else
      redirect_to noticia_path(@artigo.slug), alert: @comment.errors.full_messages.join(", ")
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:conteudo)
  end
end
