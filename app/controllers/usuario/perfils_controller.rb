class Usuario::PerfilsController < Usuario::BaseController
  def show
    @usuario = current_user
  end

  def edit
    @usuario = current_user
  end

  def update
    @usuario = current_user
    if @usuario.update(perfil_params)
      redirect_to usuario_perfil_path, notice: "Perfil atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def perfil_params
    params.require(:user).permit(:nome, :bio, :avatar_image)
  end
end
