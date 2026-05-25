class Usuario::AssinaturasController < Usuario::BaseController
  before_action :carregar_assinatura

  def show; end

  def update
    if @assinatura.update(assinatura_params)
      redirect_to usuario_assinatura_path, notice: "Assinatura atualizada."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def carregar_assinatura
    @assinatura = current_user.subscription || current_user.create_subscription!(plano: :gratuito, status: :ativa)
  end

  def assinatura_params
    params.require(:subscription).permit(:plano)
  end
end
