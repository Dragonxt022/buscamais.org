class Usuario::AssinaturasController < Usuario::BaseController
  before_action :carregar_assinatura

  def show
    @subscription = @assinatura
    @plano_atual  = current_user.plano_atual
    @planos       = SubscriptionPlan.ativos.ordenados
  end

  def update
    if @assinatura.update(assinatura_params)
      redirect_to usuario_assinatura_path, notice: "Assinatura atualizada."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def checkout
    plano = SubscriptionPlan.find(params[:plan_id])
    raise ActiveRecord::RecordNotFound if plano.gratuito?

    secret_key = SiteSetting["stripe_secret_key"].presence
    unless secret_key
      redirect_to usuario_assinatura_path, alert: "Pagamento não configurado. Contate o administrador."
      return
    end

    ::Stripe.api_key = secret_key

    customer_id = @assinatura.stripe_customer_id
    unless customer_id
      customer    = ::Stripe::Customer.create(email: current_user.email, name: current_user.nome)
      customer_id = customer.id
      @assinatura.update!(stripe_customer_id: customer_id)
    end

    usar_promo = plano.elegivel_para_promocao?(current_user)
    usar_promo ? criar_checkout_com_promocao(plano, customer_id) : criar_checkout_normal(plano, customer_id)
  rescue ::Stripe::StripeError => e
    redirect_to usuario_assinatura_path, alert: "Erro ao iniciar pagamento: #{e.message}"
  end

  def sucesso
    plano = SubscriptionPlan.find(params[:plan_id])
    @assinatura.update!(
      subscription_plan_id:   plano.id,
      plano:                  :premium,
      status:                 :ativa,
      stripe_subscription_id: params[:session_id]
    )
    redirect_to usuario_assinatura_path, notice: "Assinatura #{plano.nome} ativada! Bem-vindo."
  end

  def cancelado
    redirect_to planos_publicos_path, notice: "Pagamento cancelado. Você pode tentar novamente quando quiser."
  end

  private

  def carregar_assinatura
    @assinatura = current_user.subscription ||
                  current_user.create_subscription!(plano: :gratuito, status: :ativa)
  end

  def assinatura_params
    params.require(:subscription).permit(:plano)
  end

  def criar_checkout_normal(plano, customer_id)
    session = ::Stripe::Checkout::Session.create(
      customer:   customer_id,
      mode:       "subscription",
      line_items: [{ price: plano.stripe_price_id, quantity: 1 }],
      success_url: sucesso_usuario_assinatura_url(plan_id: plano.id) + "&session_id={CHECKOUT_SESSION_ID}",
      cancel_url:  cancelado_usuario_assinatura_url,
      metadata:    { user_id: current_user.id, plan_id: plano.id }
    )
    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  def criar_checkout_com_promocao(plano, customer_id)
    meses = plano.meses_promocionais.to_i.clamp(1, 24)
    session = ::Stripe::Checkout::Session.create(
      customer:   customer_id,
      mode:       "subscription",
      line_items: [{ price: plano.stripe_promo_price_id, quantity: 1 }],
      subscription_data: {
        metadata: { user_id: current_user.id, plan_id: plano.id, promocao: "true" }
      },
      success_url: sucesso_usuario_assinatura_url(plan_id: plano.id, promo: "1", meses: meses) + "&session_id={CHECKOUT_SESSION_ID}",
      cancel_url:  cancelado_usuario_assinatura_url,
      metadata:    { user_id: current_user.id, plan_id: plano.id, promocao: "true", meses: meses, price_id: plano.stripe_price_id }
    )
    redirect_to session.url, allow_other_host: true, status: :see_other
  end
end
