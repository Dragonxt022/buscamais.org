class FeedSource < ApplicationRecord
  # Intervalos oferecidos no formulário (em minutos). O scheduler roda a cada
  # minuto e só busca as fontes cujo intervalo já venceu.
  INTERVALOS = [ 5, 10, 15, 30, 60, 120, 180, 360, 720, 1440 ].freeze

  belongs_to :category, optional: true
  belongs_to :author, class_name: "User", optional: true
  has_many :articles, dependent: :nullify

  validates :nome, presence: true, length: { maximum: 120 }
  validates :url, presence: true, uniqueness: true
  validates :intervalo_minutos, inclusion: { in: INTERVALOS }
  validates :limite_por_sincronizacao,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 50 }
  validate :url_valida

  before_validation :normalizar_campos

  scope :ativos, -> { where(ativo: true) }

  def devido?
    return false unless ativo?
    ultima_sincronizacao_em.nil? || ultima_sincronizacao_em <= intervalo_minutos.minutes.ago
  end

  def proxima_sincronizacao_em
    return Time.current if ultima_sincronizacao_em.nil?
    ultima_sincronizacao_em + intervalo_minutos.minutes
  end

  def intervalo_label
    return "#{intervalo_minutos} minutos" if intervalo_minutos < 60
    horas = intervalo_minutos / 60
    horas == 1 ? "1 hora" : "#{horas} horas"
  end

  def sincronizar!
    FeedSyncService.new(self).chamar
  end

  private

  def normalizar_campos
    self.nome = nome.to_s.strip
    self.url  = url.to_s.strip
  end

  def url_valida
    uri = URI.parse(url.to_s.strip)
    unless uri.is_a?(URI::HTTP) && uri.host.present?
      errors.add(:url, "deve ser um endereço http(s) válido")
    end
  rescue URI::InvalidURIError
    errors.add(:url, "deve ser um endereço http(s) válido")
  end
end
