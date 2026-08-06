class Admin::DashboardController < Admin::BaseController
  def index
    @total_artigos     = Article.count
    @total_usuarios    = User.count
    @total_leituras    = Article.sum(:visualizacoes)
    @pendentes_revisao = Article.where(status: :aguardando_revisao).count
    @comentarios_pendentes = Comment.pendentes.count
    @artigos_recentes  = Article.includes(:author, :category).order(created_at: :desc).limit(5)
  end

  def analise
    @artigos_mais_lidos = Article.publicados.order(visualizacoes: :desc).limit(10)
    @leituras_por_mes   = Article.publicados
                                 .group("DATE_FORMAT(publicado_em, '%Y-%m')")
                                 .sum(:visualizacoes)
    @usuarios_por_plano = SubscriptionPlan.ativos.ordenados.map do |plano|
      count = Subscription.ativas.where(subscription_plan_id: plano.id).count
      count += User.ativos.left_joins(:subscription)
                   .where(subscriptions: { id: nil })
                   .count if plano.gratuito?
      { plano: plano, count: count }
    end
    @novos_usuarios_30d  = User.where("created_at > ?", 30.days.ago).count
    @comentarios_por_mes = Comment.group("DATE_FORMAT(created_at, '%Y-%m')").count

    @leituras_diarias = ReadingHistory.where("lido_em >= ?", 30.days.ago)
                                       .group("DATE_FORMAT(lido_em, '%Y-%m-%d')").count
    @receita_por_mes  = SubscriptionHistory.where(status: "ativa").group("DATE_FORMAT(created_at, '%Y-%m')").sum(:valor)
    @top_categorias   = Category.joins(:articles).where(articles: { status: :publicado })
                                 .group(:nome).order(Arel.sql("SUM(articles.visualizacoes) DESC"))
                                 .limit(8).sum("articles.visualizacoes")

    @top_autores = User.pode_publicar
                       .joins(:articles)
                       .where(articles: { status: :publicado })
                       .group("users.id")
                       .order("COUNT(articles.id) DESC")
                       .limit(5)
                       .select("users.*, COUNT(articles.id) AS total_artigos, SUM(articles.visualizacoes) AS total_views")
  end
end
