class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :nome, use: [:slugged, :finders]

  has_many :articles,     dependent: :nullify
  has_many :user_topics,  dependent: :destroy
  has_many :user_follows, as: :followable, dependent: :destroy

  validates :nome, presence: true, uniqueness: true

  before_create -> { self.ativo = true if ativo.nil? }

  scope :ativas, -> { where(ativo: true) }

  def should_generate_new_friendly_id?
    nome_changed? || slug.blank?
  end
end
