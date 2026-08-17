class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :nome, use: [:slugged, :finders]

  has_many :articles,     dependent: :nullify
  has_many :user_topics,  dependent: :destroy
  has_many :user_follows, as: :followable, dependent: :destroy

  # Ver Article#categorias_extras — artigos que citam esta categoria além da principal.
  has_many :article_categories, dependent: :destroy
  has_many :articles_extras, through: :article_categories, source: :article

  validates :nome, presence: true, uniqueness: true

  before_create -> { self.ativo = true if ativo.nil? }

  scope :ativas, -> { where(ativo: true) }

  # Categorias com pelo menos 1 artigo publicado, seja como categoria
  # principal ou como categoria extra.
  def self.com_artigos_publicados
    ids_principal = Article.publicados.distinct.pluck(:category_id).compact
    ids_extra     = ArticleCategory.joins(:article).merge(Article.publicados).distinct.pluck(:category_id)
    where(id: (ids_principal + ids_extra).uniq)
  end

  # Artigos publicados desta categoria, seja como categoria principal ou extra.
  def artigos_publicados_todos
    ids_extra = article_categories.joins(:article).merge(Article.publicados).pluck(:article_id)
    Article.publicados.where("articles.category_id = :id OR articles.id IN (:ids)", id: id, ids: ids_extra.presence || [0])
  end

  def should_generate_new_friendly_id?
    nome_changed? || slug.blank?
  end
end
