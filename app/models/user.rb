class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  enum :role, { usuario: 0, editor: 1, administrador: 2 }, default: :usuario

  has_many :articles,         foreign_key: :author_id, dependent: :nullify
  has_many :comments,         dependent: :destroy
  has_many :comment_likes,    dependent: :destroy
  has_many :notifications,     dependent: :destroy
  has_many :saved_articles,    dependent: :destroy
  has_many :saved_comments,    dependent: :destroy
  has_many :comment_reports,   dependent: :destroy
  has_many :user_topics,      dependent: :destroy
  has_many :reading_histories, dependent: :destroy
  has_many :user_follows,     foreign_key: :follower_id, dependent: :destroy
  has_many :followers,        class_name: "UserFollow", as: :followable, dependent: :destroy
  has_one  :subscription,          dependent: :destroy
  has_many :subscription_histories, dependent: :destroy

  has_one_attached :avatar_image

  scope :ativos,         -> { where(ativo: true) }
  scope :inativos,       -> { where(ativo: false) }
  scope :pode_publicar,  -> { where(role: [:editor, :administrador]) }

  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }

  before_save :gerar_slug, if: -> { slug.blank? && nome.present? }

  # ── Devise ─────────────────────────────────────────────────────────────

  def active_for_authentication?
    super && ativo?
  end

  def inactive_message
    ativo? ? super : :account_inactive
  end

  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    user = find_by(email: auth.info.email)
    if user
      user.update!(provider: auth.provider, uid: auth.uid,
                   avatar: auth.info.image.presence || user.avatar)
      return user
    end

    create(
      provider: auth.provider,
      uid:      auth.uid,
      email:    auth.info.email,
      nome:     auth.info.name.presence || auth.info.email.split("@").first,
      avatar:   auth.info.image,
      password: Devise.friendly_token[0, 20]
    )
  end

  # ── Plano e permissões ──────────────────────────────────────────────────

  def plano_atual
    @plano_atual ||= subscription&.plan || SubscriptionPlan.find_by(slug: "gratuito")
  end

  def plano_permissao(chave)
    plano_atual&.permissao(chave)
  end

  def badge_plano
    plano_permissao("badge").presence
  end

  def pode_salvar_mais_artigos?
    limite = plano_permissao("salvar_materias_limite").to_i
    return true if limite.zero?
    saved_articles.count < limite
  end

  def comentarios_com_moderacao?
    plano_permissao("moderacao_automatica") == true
  end

  def tempo_edicao_comentario
    plano_permissao("editar_comentario_minutos").to_i
  end

  def tem_delay_entre_comentarios?
    plano_permissao("delay_entre_comentarios") == true
  end

  def pode_denunciar?
    plano_permissao("pode_denunciar") == true
  end

  def pode_seguir?
    plano_permissao("pode_seguir") == true
  end

  def destaque_comentarios?
    plano_permissao("destaque_visual_comentarios") == true
  end

  # ── Seguir ──────────────────────────────────────────────────────────────

  def seguindo?(target)
    user_follows.exists?(followable: target)
  end

  # ── Acesso a artigos premium ─────────────────────────────────────────────

  LIMITE_PREMIUM_GRATUITO = 5 # artigos premium/mês para usuários sem assinatura

  def assinante_ativo?
    subscription&.ativa? && subscription&.premium?
  end

  def artigos_premium_lidos_mes
    reading_histories.joins(:article)
                     .where(articles: { premium: true })
                     .where("reading_histories.created_at >= ?", Time.current.beginning_of_month)
                     .count
  end

  def artigo_ja_lido?(artigo)
    reading_histories.exists?(article: artigo)
  end

  def pode_ler_premium?(artigo)
    return true if assinante_ativo?
    return true if artigo_ja_lido?(artigo) # já consumiu o crédito antes
    artigos_premium_lidos_mes < LIMITE_PREMIUM_GRATUITO
  end

  def artigos_premium_restantes_mes
    [LIMITE_PREMIUM_GRATUITO - artigos_premium_lidos_mes, 0].max
  end

  # ── Helpers ─────────────────────────────────────────────────────────────

  def admin?
    administrador?
  end

  def pode_publicar?
    editor? || administrador?
  end

  private

  def gerar_slug
    base = nome.downcase
               .gsub(/[áàãâä]/, "a").gsub(/[éèêë]/, "e")
               .gsub(/[íìîï]/, "i").gsub(/[óòõôö]/, "o")
               .gsub(/[úùûü]/, "u").gsub(/[ç]/, "c")
               .gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, "-").strip
    candidate = base
    n = 1
    while User.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end
end
