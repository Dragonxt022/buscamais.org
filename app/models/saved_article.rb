class SavedArticle < ApplicationRecord
  belongs_to :user
  belongs_to :article

  validates :user_id, uniqueness: { scope: :article_id, message: "artigo já salvo" }
end
