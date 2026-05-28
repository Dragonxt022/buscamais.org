class SubscriptionPlan < ApplicationRecord
  PERMISSOES_DEFINICOES = {
    "salvar_materias_limite"                   => { tipo: :numero, label: "Limite de salvamentos (0 = ilimitado)" },
    "editar_comentario_minutos"                => { tipo: :numero, label: "Tempo para editar comentário (minutos)" },
    "moderacao_automatica"                     => { tipo: :boolean, label: "Comentários entram em moderação automática" },
    "delay_entre_comentarios"                  => { tipo: :boolean, label: "Delay obrigatório entre comentários" },
    "aprovacao_automatica_apos_reputacao"      => { tipo: :boolean, label: "Aprovação automática após reputação mínima" },
    "badge"                                    => { tipo: :texto, label: "Badge (ex: plus, max — deixe vazio para nenhum)" },
    "notificacoes_avancadas"                   => { tipo: :boolean, label: "Notificações avançadas" },
    "historico_comentarios"                    => { tipo: :boolean, label: "Histórico de comentários" },
    "pode_denunciar"                           => { tipo: :boolean, label: "Pode denunciar comentários" },
    "pode_seguir"                              => { tipo: :boolean, label: "Pode seguir autores e categorias" },
    "destaque_visual_comentarios"              => { tipo: :boolean, label: "Destaque visual nos comentários" },
    "pode_fixar_comentario"                    => { tipo: :boolean, label: "Pode fixar comentário próprio" },
    "acesso_antecipado"                        => { tipo: :boolean, label: "Acesso antecipado a matérias" },
    "pode_criar_enquetes"                      => { tipo: :boolean, label: "Pode criar enquetes em comentários" },
    "sem_anuncios"                             => { tipo: :boolean, label: "Experiência sem anúncios" }
  }.freeze

  CORES = %w[gray blue purple amber].freeze

  has_many :subscriptions, foreign_key: :plano_id, dependent: :nullify

  validates :nome, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_-]+\z/ }
  validates :preco, numericality: { greater_than_or_equal_to: 0 }
  validates :cor, inclusion: { in: CORES }

  before_validation :gerar_slug, if: -> { slug.blank? && nome.present? }

  scope :ativos,    -> { where(ativo: true) }
  scope :ordenados, -> { order(:posicao, :id) }

  def permissao(chave)
    (permissoes || {})[chave.to_s]
  end

  def gratuito?
    preco.to_f.zero?
  end

  def preco_formatado
    return "Grátis" if gratuito?
    "R$ #{format('%.2f', preco).gsub('.', ',')}/mês"
  end

  def preco_promo_formatado
    return nil unless preco_promocional.present?
    "R$ #{format('%.2f', preco_promocional).gsub('.', ',')}/mês"
  end

  # Retorna true se a promoção está ativa e há um Price ID configurado
  def promocao_disponivel?
    promocao_ativa? && preco_promocional.present? && stripe_promo_price_id.present?
  end

  # Verifica se este usuário é elegível para a promoção
  def elegivel_para_promocao?(user)
    return false unless promocao_disponivel?
    return true unless apenas_novos_usuarios?
    # Novo usuário = nunca teve assinatura paga ativa neste plano
    !user.subscriptions.joins(:plan)
         .where(subscription_plans: { preco: 0.01.. })
         .where.not(status: :cancelada)
         .exists?
  end

  def cor_classes
    {
      "gray"   => { bg: "bg-gray-100",   text: "text-gray-700",   badge: "bg-gray-600",   ring: "ring-gray-200" },
      "blue"   => { bg: "bg-blue-50",    text: "text-blue-700",   badge: "bg-blue-600",   ring: "ring-blue-200" },
      "purple" => { bg: "bg-purple-50",  text: "text-purple-700", badge: "bg-purple-600", ring: "ring-purple-200" },
      "amber"  => { bg: "bg-amber-50",   text: "text-amber-700",  badge: "bg-amber-500",  ring: "ring-amber-200" }
    }[cor] || {}
  end

  private

  def gerar_slug
    self.slug = nome.downcase
                    .gsub(/[áàãâä]/, "a").gsub(/[éèêë]/, "e")
                    .gsub(/[íìîï]/, "i").gsub(/[óòõôö]/, "o")
                    .gsub(/[úùûü]/, "u").gsub(/[ç]/, "c")
                    .gsub(/[^a-z0-9\s-]/, "").gsub(/\s+/, "-").strip
  end
end
