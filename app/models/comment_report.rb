class CommentReport < ApplicationRecord
  belongs_to :user
  belongs_to :comment

  RAZOES = {
    "spam"       => "Spam ou propaganda",
    "odio"       => "Discurso de ódio",
    "violencia"  => "Violência ou ameaça",
    "falso"      => "Informação falsa",
    "assedio"    => "Assédio ou bullying",
    "outro"      => "Outro motivo"
  }.freeze

  validates :user_id,   uniqueness: { scope: :comment_id, message: "Você já denunciou este comentário." }
  validates :reason,    inclusion: { in: RAZOES.keys }
  validates :descricao, length: { maximum: 500 }, allow_blank: true

  scope :pendentes,  -> { where(resolvido: false) }
  scope :resolvidos, -> { where(resolvido: true) }
end
