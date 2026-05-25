class Usuario::DashboardController < Usuario::BaseController
  def index
    @sequencia      = ReadingHistory.sequencia_atual(current_user)
    @total_lidos    = current_user.reading_histories.count
    @topicos        = current_user.user_topics.includes(:category).map(&:category)
    @recomendados   = artigos_recomendados
    @salvos_recentes = current_user.saved_articles.includes(article: [:category, :author])
                                   .order(created_at: :desc).limit(3)
  end

  private

  def artigos_recomendados
    if current_user.user_topics.any?
      category_ids = current_user.user_topics.pluck(:category_id)
      lidos_ids    = current_user.reading_histories.pluck(:article_id)
      Article.publicados
             .where(category_id: category_ids)
             .where.not(id: lidos_ids)
             .includes(:category, :author)
             .order(publicado_em: :desc)
             .limit(6)
    else
      Article.publicados.includes(:category, :author).order(publicado_em: :desc).limit(6)
    end
  end
end
