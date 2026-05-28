class Article < ApplicationRecord
  extend FriendlyId
  friendly_id :titulo, use: [:slugged, :finders]

  belongs_to :author, class_name: "User"
  belongs_to :category, optional: true

  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags
  has_many :comments, dependent: :destroy
  has_many :saved_articles, dependent: :destroy
  has_many :reading_histories, dependent: :destroy

  has_one_attached :imagem_capa_file
  has_rich_text :conteudo

  enum :status, { rascunho: 0, aguardando_revisao: 1, agendado: 2, publicado: 3, arquivado: 4 }, default: :rascunho

  validates :titulo, presence: true, length: { minimum: 5, maximum: 200 }
  validates :resumo, length: { maximum: 500 }, allow_blank: true

  scope :publicados,     -> { where(status: :publicado).where("publicado_em <= ?", Time.current) }
  scope :destaques,      -> { where(destaque: true) }
  scope :recentes,       -> { order(publicado_em: :desc) }
  scope :por_categoria,  ->(categoria) { where(category: categoria) }
  scope :premium_only,   -> { where(premium: true) }
  scope :gratuitos_only, -> { where(premium: false) }

  before_save :calcular_tempo_leitura
  before_save :definir_publicado_em

  def should_generate_new_friendly_id?
    titulo_changed? || slug.blank?
  end

  private

  def calcular_tempo_leitura
    return unless conteudo.present?
    texto = conteudo.body.to_plain_text rescue conteudo.to_s
    palavras = texto.split.size
    self.tempo_leitura = [(palavras / 200.0).ceil, 1].max
  end

  def definir_publicado_em
    self.publicado_em = Time.current if publicado? && publicado_em.blank?
  end

end
