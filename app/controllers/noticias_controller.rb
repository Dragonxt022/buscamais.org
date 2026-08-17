class NoticiasController < ApplicationController

  def index
    @destaques = Article.publicados.destaques
                        .with_attached_imagem_capa_file
                        .includes(:author, :category)
                        .order(publicado_em: :desc)
                        .limit(5)
                        .to_a
    @destaques = Article.publicados
                        .with_attached_imagem_capa_file
                        .includes(:author, :category)
                        .order(publicado_em: :desc)
                        .limit(5)
                        .to_a if @destaques.empty?

    excluir_ids = @destaques.map(&:id)

    @secundarias = Article.publicados
                           .with_attached_imagem_capa_file
                           .includes(:author, :category)
                           .where.not(id: excluir_ids)
                           .order(Arel.sql("destaque DESC"), publicado_em: :desc)
                           .limit(4)

    @mais_lidos = Article.publicados
                          .with_attached_imagem_capa_file
                          .includes(:author, :category)
                          .order(visualizacoes: :desc)
                          .limit(5)

    # Conta artigos publicados de cada categoria (principal + extras) para decidir
    # quais categorias já têm volume suficiente para ganhar uma seção na home.
    categorias_ativas = Category.ativas.com_artigos_publicados
                                 .map { |cat| [cat, cat.artigos_publicados_todos.count] }
                                 .select { |_, total| total >= 3 }
                                 .sort_by { |_, total| -total }
                                 .first(4)
                                 .map(&:first)

    # As seções por categoria mostram os melhores artigos de cada categoria
    # independente do que já apareceu no slider/secundárias: com poucos artigos
    # no site, excluir esses IDs deixava blocos praticamente vazios (ex.: Saúde
    # com 1 card só). Repetir uma matéria no destaque e na sua categoria é
    # prática normal de portal de notícias, não duplicidade de conteúdo.
    @por_categoria = categorias_ativas.map do |cat|
      artigos = cat.artigos_publicados_todos
                    .with_attached_imagem_capa_file
                    .includes(:author)
                    .order(publicado_em: :desc)
                    .limit(4)
      [cat, artigos]
    end.reject { |_, artigos| artigos.empty? }

    @pagy, @ultimas = pagy(
      Article.publicados
             .with_attached_imagem_capa_file
             .includes(:author, :category)
             .order(publicado_em: :desc),
      limit: 8
    )
  end

  def show
    @artigo = Article.publicados.friendly.find(params[:slug])
    @artigo.increment!(:visualizacoes)

    # ── Verificação de acesso premium ──────────────────────────────────────
    @acesso_completo = verificar_acesso(@artigo)

    # Só carrega comentários e relacionados se tiver acesso completo
    if @acesso_completo
      @sort_comentarios = params[:sort].in?(%w[top novo]) ? params[:sort] : "top"
      ordem = @sort_comentarios == "top" ?
        Arel.sql("(SELECT COUNT(*) FROM comment_likes WHERE comment_likes.comment_id = comments.id) DESC, comments.created_at DESC") :
        Arel.sql("comments.created_at DESC")

      @comentarios = @artigo.comments.aprovados.raiz
                            .includes(:user, comment_likes: :user,
                                      replies: [:user, :comment_likes,
                                               { replies: [:user, :comment_likes] }])
                            .order(ordem)
      @artigos_relacionados = Article.publicados
                                     .with_attached_imagem_capa_file
                                     .where(category: @artigo.category)
                                     .where.not(id: @artigo.id)
                                     .order(publicado_em: :desc)
                                     .limit(3)

      # Registra leitura apenas quando teve acesso completo
      if user_signed_in?
        ReadingHistory.find_or_create_by(user: current_user, article: @artigo) do |h|
          h.lido_em = Time.current
        end
      end
    else
      # Para usuários logados, carrega o número de artigos restantes
      @artigos_premium_restantes = user_signed_in? ? current_user.artigos_premium_restantes_mes : 0
      @plano_com_promo = SubscriptionPlan.ativos.ordenados
                                         .select { |p| p.promocao_visivel? && (!user_signed_in? || p.elegivel_para_promocao?(current_user)) }
                                         .first
      @plano_pago = SubscriptionPlan.ativos.ordenados.find { |p| !p.gratuito? && p.destaque? } ||
                    SubscriptionPlan.ativos.ordenados.find { |p| !p.gratuito? }
    end
  end

  def todas
    @pagy, @artigos = pagy(
      Article.publicados
             .with_attached_imagem_capa_file
             .includes(:author, :category)
             .order(publicado_em: :desc),
      limit: 12
    )
  end

  def categoria
    @categoria = Category.friendly.find(params[:slug])
    @pagy, @artigos = pagy(
      @categoria.artigos_publicados_todos
                         .with_attached_imagem_capa_file
                         .includes(:author)
                         .order(publicado_em: :desc),
      limit: 12
    )
    @seguindo         = user_signed_in? && current_user.seguindo?(@categoria)
    @total_seguidores = UserFollow.where(followable: @categoria).count
  end

  private

  def verificar_acesso(artigo)
    return true unless artigo.premium?

    # Admins e editores têm acesso total
    return true if user_signed_in? && current_user.pode_publicar?

    # Assinante ativo tem acesso total
    return true if user_signed_in? && current_user.assinante_ativo?

    # Usuário logado com cota mensal disponível
    return true if user_signed_in? && current_user.pode_ler_premium?(artigo)

    false
  end
end
