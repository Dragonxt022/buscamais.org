class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload    = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    secret     = SiteSetting["stripe_webhook_secret"].presence

    begin
      event = secret.present? ?
        ::Stripe::Webhook.construct_event(payload, sig_header, secret) :
        ::Stripe::Event.construct_from(JSON.parse(payload))
    rescue JSON::ParserError, ::Stripe::SignatureVerificationError
      head :bad_request and return
    end

    case event.type
    when "checkout.session.completed"
      handle_checkout_completed(event.data.object)
    when "customer.subscription.deleted", "customer.subscription.updated"
      handle_subscription_update(event.data.object)
    end

    head :ok
  end

  private

  def handle_checkout_completed(session)
    user_id  = session.metadata["user_id"]
    plan_id  = session.metadata["plan_id"]
    promocao = session.metadata["promocao"] == "true"
    meses    = session.metadata["meses"].to_i
    price_id = session.metadata["price_id"] # preço normal (fase 2)

    return unless user_id && plan_id

    user = User.find_by(id: user_id)
    plan = SubscriptionPlan.find_by(id: plan_id)
    return unless user && plan

    sub = user.subscription || user.build_subscription
    sub.update!(
      subscription_plan_id:   plan.id,
      plano:                  :premium,
      status:                 :ativa,
      stripe_subscription_id: session.subscription,
      stripe_customer_id:     session.customer,
      prox_cobranca:          Date.today + meses.months
    )

    # Cria o Schedule para transição automática após o período promocional
    if promocao && meses > 0 && price_id.present? && session.subscription.present?
      criar_subscription_schedule(session.subscription, price_id, meses)
    end
  end

  def criar_subscription_schedule(subscription_id, regular_price_id, meses)
    ::Stripe.api_key = SiteSetting["stripe_secret_key"].presence
    return unless ::Stripe.api_key

    # Converte a assinatura existente em um Schedule com 2 fases
    schedule = ::Stripe::SubscriptionSchedule.create(
      from_subscription: subscription_id
    )

    ::Stripe::SubscriptionSchedule.update(
      schedule.id,
      {
        end_behavior: "release",
        phases: [
          {
            items:      [{ price: schedule.phases.first.items.first.price, quantity: 1 }],
            iterations: meses
          },
          {
            items: [{ price: regular_price_id, quantity: 1 }]
          }
        ]
      }
    )
  rescue ::Stripe::StripeError => e
    Rails.logger.error "[::Stripe Schedule] Erro ao criar schedule: #{e.message}"
  end

  def handle_subscription_update(stripe_sub)
    sub = Subscription.find_by(stripe_subscription_id: stripe_sub.id)
    return unless sub

    if stripe_sub.status.in?(["canceled", "unpaid", "past_due"])
      sub.update!(status: :cancelada, plano: :gratuito, subscription_plan_id: nil)
    end
  end
end
