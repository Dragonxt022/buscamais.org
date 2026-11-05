class Article < ApplicationRecord
  extend FriendlyId
  friendly_id :titulo, use: [:slugged, :finders]

  belongs_to :author, class_name: "User"
  belongs_to :category, optional: true
  belongs_to :feed_source, optional: true

  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags

  # Categoria adicionais além da principal (category_id) — ex.: uma notícia de
  # Cujubim marcada também em "Mundo". A categoria principal continua sendo a
  # usada para o badge/cor no card; as extras só afetam em quais páginas de
  # categoria a notícia aparece.
  has_many :article_categories, dependent: :destroy
  has_many :categorias_extras, through: :article_categories, source: :category
  has_many :comments, dependent: :destroy
  has_many :saved_articles, dependent: :destroy
  has_many :reading_histories, dependent: :destroy

  has_one_attached :imagem_capa_file
  has_rich_text :conteudo

  enum :status, { rascunho: 0, aguardando_revisao: 1, agendado: 2, publicado: 3, arquivado: 4 }, default: :rascunho

  # Quantas notícias publicadas podem ficar marcadas como destaque ao mesmo
  # tempo. Acima disso, a mais antiga (por publicado_em) perde o destaque
  # automaticamente — evita que a marcação vá se acumulando e perca o sentido
  # (o carrossel da home só gira as 5 mais recentes de qualquer forma).
  LIMITE_DESTAQUES = 8

  validates :titulo, presence: true, length: { minimum: 5, maximum: 200 }
  validates :resumo, length: { maximum: 500 }, allow_blank: true

  scope :publicados,     -> { where(status: :publicado).where("publicado_em <= ?", Time.current) }
  scope :destaques,      -> { where(destaque: true) }
  scope :recentes,       -> { order(publicado_em: :desc) }
  scope :por_categoria,  ->(categoria) { where(category: categoria) }
  scope :premium_only,   -> { where(premium: true) }
  scope :gratuitos_only, -> { where(premium: false) }
  scope :importados,     -> { where.not(feed_source_id: nil) }

  # Usado pelo reprocessamento com IA: mantém a URL antiga para não quebrar
  # links já indexados quando o título é substituído.
  attr_accessor :preservar_slug

  before_save :calcular_tempo_leitura
  before_save :definir_publicado_em
  after_save :manter_limite_de_destaques,
             if: -> { destaque? && publicado? && (saved_change_to_destaque? || saved_change_to_status?) }

  def should_generate_new_friendly_id?
    return false if preservar_slug
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

  def manter_limite_de_destaques
    excedente = self.class.publicados.destaques.count - LIMITE_DESTAQUES
    return unless excedente > 0

    self.class.publicados.destaques
        .where.not(id: id)
        .order(publicado_em: :asc)
        .limit(excedente)
        .update_all(destaque: false)
  end

end
