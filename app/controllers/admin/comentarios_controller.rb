class Admin::ComentariosController < Admin::BaseController

  before_action :carregar_comentario, only: [:show, :update, :destroy, :aprovar, :rejeitar]

  def index
    scope = Comment.includes(:user, :article).order(created_at: :desc)
    scope = scope.where(status: params[:status]) if params[:status].present?
    @pagy, @comentarios = pagy(scope)
  end

  def show; end

  def update
    @comentario.update(comentario_params)
    redirect_to admin_comentarios_path, notice: "Comentário atualizado."
  end

  def destroy
    @comentario.destroy
    redirect_to admin_comentarios_path, notice: "Comentário removido."
  end

  def bulk_destroy
    ids = Array(params[:ids]).map(&:to_i)
    count = Comment.where(id: ids).destroy_all.size
    redirect_to admin_comentarios_path, notice: "#{count} comentário(s) removido(s)."
  end

  def aprovar
    @comentario.update!(status: :aprovado)
    Notification.notificar_aprovacao(@comentario)
    redirect_to admin_comentarios_path, notice: "Comentário aprovado."
  end

  def rejeitar
    @comentario.update!(status: :rejeitado)
    redirect_to admin_comentarios_path, notice: "Comentário rejeitado."
  end

  private

  def carregar_comentario
    @comentario = Comment.find(params[:id])
  end

  def comentario_params
    params.require(:comment).permit(:conteudo, :status)
  end
end
