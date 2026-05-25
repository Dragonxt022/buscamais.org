class Usuario::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :redirecionar_se_privilegiado

  layout "usuario"

  private

  def redirecionar_se_privilegiado
    if current_user.administrador?
      redirect_to admin_root_path
    elsif current_user.editor?
      redirect_to editor_root_path
    end
  end
end
