class ContactMessage < ApplicationRecord
  validates :nome,     presence: true
  validates :email,    presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :assunto,  presence: true
  validates :mensagem, presence: true

  scope :nao_lidas,    -> { where(lida: false) }
  scope :nao_respondidas, -> { where(respondida: false) }
  scope :recentes,     -> { order(created_at: :desc) }

  ASSUNTOS = {
    "duvida"    => "Dúvida geral",
    "pauta"     => "Sugestão de pauta",
    "correcao"  => "Denúncia / correção",
    "parceria"  => "Parceria comercial",
    "curriculo" => "Currículo espontâneo",
    "outro"     => "Outro"
  }.freeze

  def assunto_label
    ASSUNTOS[assunto] || assunto.humanize
  end

  def marcar_lida!
    update!(lida: true) unless lida?
  end
end
