class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :requer_admin!
  before_action :carregar_notificacoes_count

  layout "admin"

  private

  def carregar_notificacoes_count
    @notificacoes_nao_lidas_count = current_user.notifications.nao_lidas.count
    @notificacoes_dropdown        = current_user.notifications.recentes.limit(8)
  end
end
