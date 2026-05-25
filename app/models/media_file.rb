class MediaFile < ApplicationRecord
  belongs_to :user

  has_one_attached :arquivo

  TIPOS_PERMITIDOS = %w[image/jpeg image/png image/gif image/webp video/mp4 application/pdf].freeze

  validates :nome, presence: true
  validate :tipo_de_arquivo_permitido

  scope :imagens, -> { where(tipo: %w[image/jpeg image/png image/gif image/webp]) }
  scope :recentes, -> { order(created_at: :desc) }

  def imagem?
    tipo&.start_with?("image/")
  end

  def tamanho_formatado
    return "-" unless tamanho
    tamanho < 1.megabyte ? "#{(tamanho / 1024.0).round(1)} KB" : "#{(tamanho / 1.megabyte.to_f).round(1)} MB"
  end

  def dimensoes
    return nil unless largura && altura
    "#{largura} × #{altura}"
  end

  private

  def tipo_de_arquivo_permitido
    return unless arquivo.attached?
    unless TIPOS_PERMITIDOS.include?(arquivo.content_type)
      errors.add(:arquivo, "tipo não permitido")
    end
  end
end
