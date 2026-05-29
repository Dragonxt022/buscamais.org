class Usuario::ResumosController < Usuario::BaseController

  def show
    @data   = Date.current
    @topicos = current_user.user_topics.includes(:category).map(&:category)

    base = Article.publicados
                  .where("DATE(publicado_em) = ?", @data)
                  .includes(:category, image_attachment: :blob)
                  .order(publicado_em: :desc)

    @artigos_hoje = base.to_a

    if @topicos.any?
      topic_ids = @topicos.map(&:id).to_set
      @por_topico = @topicos.filter_map do |cat|
        arts = @artigos_hoje.select { |a| a.category_id == cat.id }
        [cat, arts] if arts.any?
      end
      @outros = @artigos_hoje.reject { |a| topic_ids.include?(a.category_id) }
    else
      @por_topico = []
      @outros     = @artigos_hoje
    end

    @lidos = current_user.reading_histories
                         .where(article_id: @artigos_hoje.map(&:id))
                         .pluck(:article_id).to_set

    # Fallback: últimos 3 dias se não publicou nada hoje
    if @artigos_hoje.empty?
      @artigos_recentes = Article.publicados
                                 .where("publicado_em >= ?", 3.days.ago)
                                 .includes(:category, image_attachment: :blob)
                                 .order(publicado_em: :desc)
                                 .limit(12)
    end
  end
end
