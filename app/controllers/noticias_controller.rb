class NoticiasController < ApplicationController

  def index
    @artigo_destaque = Article.publicados.destaques
                              .with_attached_imagem_capa_file
                              .includes(:author, :category)
                              .order(publicado_em: :desc).first
    @pagy, @ultimas = pagy(
      Article.publicados
             .with_attached_imagem_capa_file
             .includes(:author, :category)
             .order(publicado_em: :desc),
      limit: 12
    )
  end

  def show
    @artigo = Article.publicados.friendly.find(params[:slug])
    @artigo.increment!(:visualizacoes)
    @comentarios = @artigo.comments.aprovados.raiz
                          .includes(:user, comment_likes: :user,
                                    replies: [:user, :comment_likes,
                                             { replies: [:user, :comment_likes] }])
                          .recentes
    @artigos_relacionados = Article.publicados
                                   .with_attached_imagem_capa_file
                                   .where(category: @artigo.category)
                                   .where.not(id: @artigo.id)
                                   .order(publicado_em: :desc)
                                   .limit(3)

    if user_signed_in?
      ReadingHistory.find_or_create_by(user: current_user, article: @artigo) do |h|
        h.lido_em = Time.current
      end
    end
  end

  def categoria
    @categoria = Category.friendly.find(params[:slug])
    @pagy, @artigos = pagy(
      @categoria.articles.publicados
                         .with_attached_imagem_capa_file
                         .includes(:author)
                         .order(publicado_em: :desc),
      limit: 12
    )
  end
end
