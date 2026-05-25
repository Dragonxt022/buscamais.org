class ReadingHistory < ApplicationRecord
  belongs_to :user
  belongs_to :article

  validates :user_id, uniqueness: { scope: :article_id }

  scope :recentes, -> { order(lido_em: :desc) }

  def self.sequencia_atual(user)
    historico = where(user: user).order(lido_em: :desc).pluck(:lido_em)
    return 0 if historico.empty?

    sequencia = 1
    historico.each_cons(2) do |mais_recente, anterior|
      break unless mais_recente.to_date - anterior.to_date == 1
      sequencia += 1
    end
    sequencia
  end
end
