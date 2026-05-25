class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :article

  enum :status, { pendente: 0, aprovado: 1, rejeitado: 2 }, default: :pendente

  validates :conteudo, presence: true, length: { minimum: 3, maximum: 2000 }

  scope :aprovados, -> { where(status: :aprovado) }
  scope :pendentes, -> { where(status: :pendente) }
  scope :recentes, -> { order(created_at: :desc) }
end
