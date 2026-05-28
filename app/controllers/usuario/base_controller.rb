class Usuario::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :redirecionar_se_privilegiado

  layout "usuario"

  private

  # Redireciona admins/editores para sua área própria, exceto para páginas
  # pessoais (configurações, perfil, salvos, notificações) que são universais.
  PAGINAS_PESSOAIS = %w[
    usuario/configuracoes
    usuario/perfis
    usuario/salvos
    usuario/notificacoes
    usuario/comentarios
    usuario/assinaturas
    usuario/follows
  ].freeze

  def redirecionar_se_privilegiado
    return if PAGINAS_PESSOAIS.any? { |c| controller_path.start_with?(c) }

    if current_user.administrador?
      redirect_to admin_root_path
    elsif current_user.editor?
      redirect_to editor_root_path
    end
  end
end
