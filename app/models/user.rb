class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  enum :role, { usuario: 0, editor: 1, administrador: 2 }, default: :usuario

  has_many :articles,         foreign_key: :author_id, dependent: :nullify
  has_many :comments,         dependent: :destroy
  has_many :comment_likes,    dependent: :destroy
  has_many :notifications,    dependent: :destroy
  has_many :saved_articles,   dependent: :destroy
  has_many :user_topics,      dependent: :destroy
  has_many :reading_histories, dependent: :destroy
  has_one  :subscription,     dependent: :destroy

  has_one_attached :avatar_image

  scope :ativos,   -> { where(ativo: true) }
  scope :inativos, -> { where(ativo: false) }

  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }

  # Devise: impede login de usuários desativados
  def active_for_authentication?
    super && ativo?
  end

  def inactive_message
    ativo? ? super : :account_inactive
  end

  def self.from_omniauth(auth)
    # Usuário já logou com Google antes
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    # Conta com esse e-mail já existe → vincula o Google sem criar nova conta
    user = find_by(email: auth.info.email)
    if user
      user.update!(provider: auth.provider, uid: auth.uid)
      return user
    end

    # Primeiro acesso — cria a conta automaticamente
    create!(
      provider: auth.provider,
      uid:      auth.uid,
      email:    auth.info.email,
      nome:     auth.info.name.presence || auth.info.email.split("@").first,
      password: Devise.friendly_token[0, 20]
    )
  end

  def admin?
    administrador?
  end

  def pode_publicar?
    editor? || administrador?
  end
end
