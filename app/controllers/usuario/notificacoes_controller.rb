class Usuario::NotificacoesController < Usuario::BaseController
  def index
    @pagy, @notificacoes = pagy(
      current_user.notifications.recentes.includes(:notificable),
      limit: 20
    )
  end

  def destroy
    current_user.notifications.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to usuario_notificacoes_path, notice: "Notificação removida." }
      format.json { head :no_content }
    end
  end

  def marcar_lida
    current_user.notifications.find(params[:id]).update!(lida: true)
    respond_to do |format|
      format.html { redirect_back fallback_location: usuario_notificacoes_path }
      format.json { render json: { ok: true } }
    end
  end

  def marcar_todas_lidas
    current_user.notifications.nao_lidas.update_all(lida: true)
    respond_to do |format|
      format.html { redirect_to usuario_notificacoes_path, notice: "Todas as notificações marcadas como lidas." }
      format.json { render json: { ok: true } }
    end
  end

  def bulk_destroy
    ids = Array(params[:ids]).map(&:to_i)
    current_user.notifications.where(id: ids).destroy_all
    respond_to do |format|
      format.html { redirect_to usuario_notificacoes_path, notice: "Notificações removidas." }
      format.json { head :no_content }
    end
  end
end
