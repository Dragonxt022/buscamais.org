class CommentSavesController < ApplicationController
  before_action :authenticate_user!

  def create
    comment = Comment.aprovados.find(params[:comment_id])
    current_user.saved_comments.find_or_create_by!(comment: comment)
    respond_to do |format|
      format.json { render json: { saved: true } }
      format.html { redirect_back_or_to noticia_path(comment.article.slug, anchor: "comentario-#{comment.id}"),
                                         notice: "Comentário salvo." }
    end
  end

  def destroy
    saved = current_user.saved_comments.find_by(comment_id: params[:comment_id])
    saved&.destroy
    respond_to do |format|
      format.json { render json: { saved: false } }
      format.html { redirect_back_or_to noticia_path(saved.comment.article.slug, anchor: "comentario-#{saved.comment_id}"),
                                         notice: "Comentário removido dos salvos." }
    end
  end
end
