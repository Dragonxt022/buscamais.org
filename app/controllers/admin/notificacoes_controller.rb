class Admin::NotificacoesController < Admin::BaseController
  def index
    @pagy, @notificacoes = pagy(current_user.notifications.recentes, limit: 20)
    current_user.notifications.nao_lidas.update_all(lida: true)
    @notificacoes_nao_lidas_count = 0
    @notificacoes_dropdown        = @notificacoes.first(8)
  end

  def destroy
    current_user.notifications.find(params[:id]).destroy
    redirect_to admin_notificacoes_path, status: :see_other
  end

  def marcar_todas_lidas
    current_user.notifications.nao_lidas.update_all(lida: true)
    redirect_to admin_notificacoes_path, notice: "Todas as notificações foram marcadas como lidas."
  end
end
