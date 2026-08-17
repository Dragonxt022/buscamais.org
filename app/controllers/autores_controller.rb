class AutoresController < ApplicationController
  def index
    @autores = User.pode_publicar
                   .joins(:articles).merge(Article.publicados)
                   .distinct
                   .order(:nome)
  end

  def show
    @autor = User.pode_publicar.find_by!(slug: params[:slug])
    @pagy, @artigos = pagy(
      @autor.articles.publicados
                     .with_attached_imagem_capa_file
                     .includes(:category)
                     .order(publicado_em: :desc),
      limit: 9
    )
    @total_artigos   = @autor.articles.publicados.count
    @total_leituras  = @autor.articles.publicados.sum(:visualizacoes)
    @seguindo        = user_signed_in? && current_user.seguindo?(@autor)
    @total_seguidores = UserFollow.where(followable: @autor).count
  end
end
