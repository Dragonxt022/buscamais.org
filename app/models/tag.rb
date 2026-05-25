class Tag < ApplicationRecord
  extend FriendlyId
  friendly_id :nome, use: :slugged

  has_many :article_tags, dependent: :destroy
  has_many :articles, through: :article_tags

  validates :nome, presence: true, uniqueness: true
end
