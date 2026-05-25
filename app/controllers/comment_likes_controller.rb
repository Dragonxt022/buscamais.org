class CommentLikesController < ApplicationController
  before_action :authenticate_user!

  def toggle
    @comment = Comment.aprovados.find(params[:id])
    existing = @comment.comment_likes.find_by(user: current_user)

    if existing
      existing.destroy
      liked = false
    else
      @comment.comment_likes.create!(user: current_user)
      Notification.notificar_curtida(CommentLike.find_by(comment: @comment, user: current_user))
      liked = true
    end

    respond_to do |format|
      format.json do
        render json: { liked: liked, count: @comment.reload.likes_count }
      end
      format.html do
        redirect_back fallback_location: root_path
      end
    end
  end
end
