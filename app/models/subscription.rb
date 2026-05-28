class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :plan, class_name: "SubscriptionPlan", foreign_key: :subscription_plan_id, optional: true

  enum :plano, { gratuito: 0, premium: 1 }, default: :gratuito
  enum :status, { ativa: 0, cancelada: 1, expirada: 2 }, default: :ativa

  validates :status, presence: true

  scope :ativas, -> { where(status: :ativa) }

  def premium?
    plan.present? ? (plan.preco.to_f > 0 && ativa?) : (plano == "premium" && ativa?)
  end

  def nome_plano
    plan&.nome || (premium? ? "Premium" : "Gratuito")
  end
end
