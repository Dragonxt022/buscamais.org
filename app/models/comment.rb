class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :article
  belongs_to :parent, class_name: "Comment", optional: true
  has_many   :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many   :comment_likes, dependent: :destroy
  has_many   :likers, through: :comment_likes, source: :user

  enum :status, { pendente: 0, aprovado: 1, rejeitado: 2 }, default: :pendente

  validates :conteudo, presence: true, length: { minimum: 3, maximum: 2000 }
  validate  :max_depth

  scope :aprovados,      -> { where(status: :aprovado) }
  scope :pendentes,      -> { where(status: :pendente) }
  scope :recentes,       -> { order(created_at: :desc) }
  scope :raiz,           -> { where(parent_id: nil) }
  scope :com_respostas,  -> { includes(replies: [:user, { replies: :user }]) }

  def profundidade
    parent_id ? (parent&.parent_id ? 2 : 1) : 0
  end

  def curtido_por?(user)
    return false unless user
    comment_likes.exists?(user: user)
  end

  private

  def max_depth
    errors.add(:base, "Máximo de 3 níveis de resposta") if profundidade >= 3
  end
end
