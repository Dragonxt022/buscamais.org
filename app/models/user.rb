class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { usuario: 0, editor: 1, administrador: 2 }, default: :usuario

  has_many :articles, foreign_key: :author_id, dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :saved_articles, dependent: :destroy
  has_many :user_topics, dependent: :destroy
  has_many :reading_histories, dependent: :destroy
  has_one  :subscription, dependent: :destroy

  has_one_attached :avatar_image

  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }

  def admin?
    administrador?
  end

  def pode_publicar?
    editor? || administrador?
  end
end
