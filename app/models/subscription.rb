class Subscription < ApplicationRecord
  belongs_to :user

  enum :plano, { gratuito: 0, premium: 1 }, default: :gratuito
  enum :status, { ativa: 0, cancelada: 1, expirada: 2 }, default: :ativa

  validates :plano, presence: true
  validates :status, presence: true

  scope :ativas, -> { where(status: :ativa) }

  def premium?
    plano == "premium" && ativa?
  end
end
