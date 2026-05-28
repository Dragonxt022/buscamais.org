class Admin::UsuariosController < Admin::BaseController

  before_action :carregar_usuario, only: [:show, :edit, :update, :destroy, :alterar_role, :toggle_ativo]

  def index
    scope = User.order(created_at: :desc)
    scope = scope.where(role: params[:role])    if params[:role].present?
    scope = scope.where(ativo: true)            if params[:status] == "ativo"
    scope = scope.where(ativo: false)           if params[:status] == "inativo"
    scope = scope.where("nome LIKE ? OR email LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
    @pagy, @usuarios = pagy(scope)
  end

  def show; end

  def edit; end

  def update
    if @usuario.update(usuario_params)
      redirect_to admin_usuarios_path, notice: "Usuário atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @usuario == current_user
      redirect_to admin_usuarios_path, alert: "Você não pode excluir sua própria conta."
      return
    end
    @usuario.destroy
    redirect_to admin_usuarios_path, notice: "Usuário removido."
  end

  def bulk_destroy
    ids = Array(params[:ids]).map(&:to_i).reject { |id| id == current_user.id }
    count = User.where(id: ids).destroy_all.size
    redirect_to admin_usuarios_path, notice: "#{count} usuário(s) removido(s)."
  end

  def toggle_ativo
    if @usuario == current_user
      redirect_to admin_usuarios_path, alert: "Você não pode desativar sua própria conta."
      return
    end
    @usuario.update!(ativo: !@usuario.ativo?)
    status = @usuario.ativo? ? "ativado" : "desativado"
    redirect_to admin_usuarios_path, notice: "Usuário #{status}."
  end

  def alterar_role
    @usuario.update!(role: params[:role])
    redirect_to admin_usuarios_path, notice: "Permissão alterada para #{User.roles.key(@usuario.role)}."
  end

  private

  def carregar_usuario
    @usuario = User.find(params[:id])
  end

  def usuario_params
    # :role é gerenciado exclusivamente via alterar_role — não via update em massa
    params.require(:user).permit(:nome, :email, :bio)
  end
end
