class Admin::ComentariosController < Admin::BaseController

  before_action :carregar_comentario, only: [:show, :update, :destroy, :aprovar, :rejeitar]

  def index
    scope = Comment.includes(:user, :article, :comment_reports).order(created_at: :desc)
    scope = scope.where(status: params[:status])        if params[:status].present?
    scope = scope.joins(:comment_reports).distinct      if params[:denunciados].present?
    if params[:q].present?
      scope = scope.joins(:user)
                   .where("comments.conteudo LIKE ? OR users.nome LIKE ?",
                          "%#{params[:q]}%", "%#{params[:q]}%")
    end

    @total_pendentes   = Comment.pendentes.count
    @total_denunciados = Comment.joins(:comment_reports).distinct.where(comment_reports: { resolvido: false }).count
    @pagy, @comentarios = pagy(scope, limit: 20)
  end

  def show; end

  def update
    @comentario.update(comentario_params)
    redirect_to admin_comentarios_path, notice: "Comentário atualizado."
  end

  def destroy
    @comentario.destroy
    redirect_back_or_to admin_comentarios_path, notice: "Comentário removido."
  end

  def bulk_destroy
    ids = Array(params[:ids]).map(&:to_i)
    count = Comment.where(id: ids).destroy_all.size
    redirect_to admin_comentarios_path, notice: "#{count} comentário(s) removido(s)."
  end

  def aprovar
    @comentario.update!(status: :aprovado)
    Notification.notificar_aprovacao(@comentario)
    # Resolve denúncias pendentes ao aprovar
    @comentario.comment_reports.update_all(resolvido: true)
    redirect_back_or_to admin_comentarios_path, notice: "Comentário aprovado."
  end

  def rejeitar
    @comentario.update!(status: :rejeitado)
    @comentario.comment_reports.update_all(resolvido: true)
    redirect_back_or_to admin_comentarios_path, notice: "Comentário rejeitado."
  end

  private

  def carregar_comentario
    @comentario = Comment.find(params[:id])
  end

  def comentario_params
    params.require(:comment).permit(:conteudo, :status)
  end
end
