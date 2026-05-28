class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notificable, polymorphic: true, optional: true

  TIPOS = %w[novo_comentario comentario_aprovado resposta curtida].freeze

  validates :tipo, inclusion: { in: TIPOS }

  scope :nao_lidas, -> { where(lida: false) }
  scope :recentes,  -> { order(created_at: :desc) }

  def self.notificar_admins_novo_comentario(comment)
    User.where(role: :administrador).find_each do |admin|
      create!(
        user:        admin,
        notificable: comment,
        tipo:        "novo_comentario",
        dados:       { autor: comment.user.nome, artigo: comment.article.titulo }.to_json
      )
    end
  end

  def self.notificar_aprovacao(comment)
    n = create!(
      user:        comment.user,
      notificable: comment,
      tipo:        "comentario_aprovado",
      dados:       { artigo: comment.article.titulo, slug: comment.article.slug }.to_json
    )
    NotificationMailer.comentario_aprovado(n).deliver_later rescue nil
    n
  end

  def self.notificar_resposta(reply)
    return unless reply.parent && reply.parent.user != reply.user
    n = create!(
      user:        reply.parent.user,
      notificable: reply,
      tipo:        "resposta",
      dados:       { autor: reply.user.nome, artigo: reply.article.titulo, slug: reply.article.slug }.to_json
    )
    NotificationMailer.nova_resposta(n).deliver_later rescue nil
    n
  end

  def self.notificar_curtida(like)
    return if like.comment.user == like.user
    n = create!(
      user:        like.comment.user,
      notificable: like.comment,
      tipo:        "curtida",
      dados:       { autor: like.user.nome, artigo: like.comment.article.titulo, slug: like.comment.article.slug }.to_json
    )
    NotificationMailer.nova_curtida(n).deliver_later rescue nil
    n
  end

  def dados_hash
    dados ? JSON.parse(dados) : {}
  end

  def icone
    { "novo_comentario" => "💬", "comentario_aprovado" => "✅", "resposta" => "↩️", "curtida" => "❤️" }[tipo] || "🔔"
  end

  def mensagem
    d = dados_hash
    case tipo
    when "novo_comentario"   then "#{d['autor']} comentou em "#{d['artigo']}""
    when "comentario_aprovado" then "Seu comentário em "#{d['artigo']}" foi aprovado"
    when "resposta"          then "#{d['autor']} respondeu seu comentário em "#{d['artigo']}""
    when "curtida"           then "#{d['autor']} curtiu seu comentário em "#{d['artigo']}""
    else "Nova notificação"
    end
  end

  def link
    d = dados_hash
    d["slug"] ? "/noticias/#{d['slug']}" : "#"
  end
end
