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
  end
end
