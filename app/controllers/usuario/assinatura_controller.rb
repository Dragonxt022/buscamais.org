class Usuario::AssinaturaController < Usuario::BaseController
  def show
    @subscription = current_user.subscription
    @plano_atual  = current_user.plano_atual
    @planos       = SubscriptionPlan.ativos.ordenados
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

    sub = current_user.subscription || current_user.build_subscription
    customer_id = sub.stripe_customer_id

    unless customer_id
      customer    = ::Stripe::Customer.create(email: current_user.email, name: current_user.nome)
      customer_id = customer.id
      sub.update!(stripe_customer_id: customer_id)
    end

    usar_promo = plano.elegivel_para_promocao?(current_user)

    if usar_promo
      criar_checkout_com_promocao(plano, customer_id)
    else
      criar_checkout_normal(plano, customer_id)
    end
  rescue ::Stripe::StripeError => e
    redirect_to usuario_assinatura_path, alert: "Erro ao iniciar pagamento: #{e.message}"
  end

  def sucesso
    plano = SubscriptionPlan.find(params[:plan_id])
    sub   = current_user.subscription || current_user.create_subscription!
    sub.update!(
      subscription_plan_id:   plano.id,
      plano:                  :premium,
      status:                 :ativa,
      stripe_subscription_id: params[:session_id]
    )
    redirect_to usuario_assinatura_path,
                notice: "Assinatura #{plano.nome} ativada! Bem-vindo."
  end

  def cancelado
    redirect_to planos_publicos_path,
                notice: "Pagamento cancelado. Você pode tentar novamente quando quiser."
  end

  def update
    sub = current_user.subscription
    if sub&.stripe_subscription_id.present?
      ::Stripe.api_key = SiteSetting["stripe_secret_key"].presence
      ::Stripe::Subscription.cancel(sub.stripe_subscription_id) rescue nil
    end
    sub&.update!(status: :cancelada, subscription_plan_id: nil, plano: :gratuito)
    redirect_to usuario_assinatura_path, notice: "Assinatura cancelada."
  end

  private

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

  # Usa ::Stripe Subscription Schedule com 2 fases:
  #   Fase 1 → preço promocional por N meses
  #   Fase 2 → preço normal (automático, sem intervenção)
  def criar_checkout_com_promocao(plano, customer_id)
    meses = plano.meses_promocionais.to_i.clamp(1, 24)

    session = ::Stripe::Checkout::Session.create(
      customer:   customer_id,
      mode:       "subscription",
      line_items: [{ price: plano.stripe_promo_price_id, quantity: 1 }],
      subscription_data: {
        metadata: { user_id: current_user.id, plan_id: plano.id, promocao: "true" },
        # Após o checkout o webhook transforma em Schedule automaticamente
      },
      success_url: sucesso_usuario_assinatura_url(
                     plan_id: plano.id,
                     promo:   "1",
                     meses:   meses
                   ) + "&session_id={CHECKOUT_SESSION_ID}",
      cancel_url:  cancelado_usuario_assinatura_url,
      metadata:    {
        user_id:   current_user.id,
        plan_id:   plano.id,
        promocao:  "true",
        meses:     meses,
        price_id:  plano.stripe_price_id
      }
    )
    redirect_to session.url, allow_other_host: true, status: :see_other
  end
end
