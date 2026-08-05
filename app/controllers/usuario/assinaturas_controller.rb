require 'stripe'

class Usuario::AssinaturasController < Usuario::BaseController
  before_action :carregar_assinatura

  def show
    @subscription = @assinatura
    @plano_atual  = current_user.plano_atual
    @planos       = SubscriptionPlan.ativos.ordenados
    @historico    = current_user.subscription_histories.recentes.includes(:subscription_plan).limit(12)
  end

  # Troca de plano para assinantes existentes via Stripe API
  def trocar_plano
    novo_plano = SubscriptionPlan.find(params[:plan_id])

    if novo_plano.gratuito?
      redirect_to usuario_assinatura_path, alert: "Para cancelar use o botão de cancelamento."
      return
    end

    if novo_plano.stripe_price_id.blank?
      redirect_to usuario_assinatura_path, alert: "Plano não configurado. Tente novamente mais tarde."
      return
    end

    secret_key = SiteSetting["stripe_secret_key"].presence
    unless secret_key && @assinatura.stripe_subscription_id.present?
      redirect_to checkout_usuario_assinatura_path(plan_id: novo_plano.id), allow_other_host: false
      return
    end

    ::Stripe.api_key = secret_key

    plano_anterior = @assinatura.plan
    eh_upgrade = novo_plano.preco.to_f > (plano_anterior&.preco.to_f || 0)

    stripe_sub = ::Stripe::Subscription.retrieve(@assinatura.stripe_subscription_id)
    item_id    = stripe_sub.items.data.first.id

    ::Stripe::Subscription.update(
      @assinatura.stripe_subscription_id,
      {
        items: [{ id: item_id, price: novo_plano.stripe_price_id }],
        proration_behavior: "none",
        billing_cycle_anchor: "unchanged"
      }
    )

    # Encerra o registro anterior no histórico
    current_user.subscription_histories
                .where(vigente_ate: nil)
                .update_all(vigente_ate: @assinatura.prox_cobranca || Time.current)

    # Registra a troca
    current_user.subscription_histories.create!(
      subscription_plan:     novo_plano,
      event_type:            eh_upgrade ? "upgradada" : "downgradada",
      valor:                 novo_plano.preco,
      status:                "ativa",
      stripe_subscription_id: @assinatura.stripe_subscription_id,
      vigente_de:            @assinatura.prox_cobranca || Time.current
    )

    @assinatura.update!(subscription_plan_id: novo_plano.id)

    tipo = eh_upgrade ? "Upgrade" : "Downgrade"
    redirect_to usuario_assinatura_path,
      notice: "#{tipo} para #{novo_plano.nome} confirmado! A cobrança de #{novo_plano.preco_formatado} começa no próximo ciclo (#{l @assinatura.prox_cobranca, format: :short rescue 'próxima renovação'})."
  rescue ::Stripe::StripeError => e
    redirect_to usuario_assinatura_path, alert: "Erro ao trocar plano: #{e.message}"
  end

  def checkout
    plano = SubscriptionPlan.find(params[:plan_id])
    raise ActiveRecord::RecordNotFound if plano.gratuito?

    secret_key = SiteSetting["stripe_secret_key"].presence
    unless secret_key
      redirect_to usuario_assinatura_path, alert: "Pagamento não configurado. Contate o administrador."
      return
    end

    if plano.stripe_price_id.blank?
      redirect_to usuario_assinatura_path, alert: "Este plano ainda não tem um Price ID do Stripe configurado."
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

    plano_anterior = @assinatura.plan

    @assinatura.update!(
      subscription_plan_id:   plano.id,
      plano:                  :premium,
      status:                 :ativa,
      stripe_subscription_id: params[:session_id]
    )

    # Encerra histórico anterior
    current_user.subscription_histories
                .where(vigente_ate: nil)
                .update_all(vigente_ate: Time.current)

    # Registra novo evento
    current_user.subscription_histories.create!(
      subscription_plan:      plano,
      event_type:             plano_anterior ? "upgradada" : "ativada",
      valor:                  plano.preco,
      status:                 "ativa",
      stripe_subscription_id: params[:session_id],
      vigente_de:             Time.current
    )

    redirect_to usuario_assinatura_path, notice: "Assinatura #{plano.nome} ativada! Bem-vindo."
  end

  def cancelado
    redirect_to planos_publicos_path, notice: "Pagamento cancelado. Você pode tentar novamente quando quiser."
  end

  def update
    sub = @assinatura
    if sub.stripe_subscription_id.present?
      ::Stripe.api_key = SiteSetting["stripe_secret_key"].presence
      ::Stripe::Subscription.cancel(sub.stripe_subscription_id) rescue nil
    end

    # Registra cancelamento no histórico
    current_user.subscription_histories
                .where(vigente_ate: nil)
                .update_all(vigente_ate: sub.prox_cobranca || Time.current)

    current_user.subscription_histories.create!(
      subscription_plan: sub.plan,
      event_type:        "cancelada",
      valor:             sub.plan&.preco || 0,
      status:            "cancelada",
      vigente_de:        sub.prox_cobranca || Time.current
    )

    sub.update!(status: :cancelada, subscription_plan_id: nil, plano: :gratuito)
    redirect_to usuario_assinatura_path, notice: "Assinatura cancelada. Você mantém o acesso até o fim do período pago."
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
      customer:             customer_id,
      mode:                 "subscription",
      payment_method_types: ["card"],
      line_items:           [{ price: plano.stripe_price_id, quantity: 1 }],
      success_url:          sucesso_usuario_assinatura_url(plan_id: plano.id) + "&session_id={CHECKOUT_SESSION_ID}",
      cancel_url:           cancelado_usuario_assinatura_url,
      metadata:             { user_id: current_user.id, plan_id: plano.id }
    )
    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  def criar_checkout_com_promocao(plano, customer_id)
    meses = plano.meses_promocionais.to_i.clamp(1, 24)
    session = ::Stripe::Checkout::Session.create(
      customer:             customer_id,
      mode:                 "subscription",
      payment_method_types: ["card"],
      line_items:           [{ price: plano.stripe_promo_price_id, quantity: 1 }],
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
