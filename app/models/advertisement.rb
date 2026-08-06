class Advertisement < ApplicationRecord
  belongs_to :user
  has_one_attached :imagem

  enum :formato, { quadrado: 0, retangular: 1, vertical: 2 }, default: :retangular

  REQUISITOS = {
    "quadrado"   => [1080, 1080],
    "retangular" => [1080, 566],
    "vertical"   => [1080, 1920]
  }.freeze

  validates :titulo, :url_destino, presence: true
  validate :imagem_presente
  validate :dimensoes_corretas

  scope :ativos_para, ->(formato) {
    where(formato: formato, ativo: true)
      .where("inicio_em IS NULL OR inicio_em <= ?", Time.current)
      .where("fim_em IS NULL OR fim_em >= ?", Time.current)
  }

  def registrar_clique!
    increment!(:cliques)
  end

  def dimensoes_exigidas
    REQUISITOS[formato]&.join("×")
  end

  # Active Storage só envia o arquivo para o service (disco/S3) quando o registro
  # é salvo — em um registro novo, o blob ainda não existe no storage durante as
  # validações. Guardamos aqui a referência ao arquivo bruto enviado no formulário
  # para poder ler as dimensões antes do save, sem depender do blob já persistido.
  attr_reader :imagem_upload_para_validacao

  def imagem=(attachable)
    @imagem_upload_para_validacao = attachable
    super
  end

  private

  def imagem_presente
    errors.add(:imagem, "é obrigatória") unless imagem.attached?
  end

  def dimensoes_corretas
    return unless imagem.attached? && formato.present?

    path = caminho_do_upload
    return unless path

    largura_esperada, altura_esperada = REQUISITOS[formato]
    img = Vips::Image.new_from_file(path)
    unless img.width == largura_esperada && img.height == altura_esperada
      errors.add(:imagem, "deve ter exatamente #{largura_esperada}×#{altura_esperada}px (enviada: #{img.width}×#{img.height}px)")
    end
  rescue => e
    Rails.logger.error "[Advertisement] Falha ao validar dimensões: #{e.message}"
    errors.add(:imagem, "não foi possível validar as dimensões da imagem")
  end

  def caminho_do_upload
    upload = imagem_upload_para_validacao
    case upload
    when ActionDispatch::Http::UploadedFile
      upload.tempfile.path
    when Hash
      io = upload[:io] || upload["io"]
      io.respond_to?(:path) ? io.path : nil
    end
  end
end
