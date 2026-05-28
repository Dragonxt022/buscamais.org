class BuscaController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    if @query.length >= 2
      @pagy, @resultados = pagy(
        Article.publicados
               .where("titulo LIKE :q OR resumo LIKE :q", q: "%#{@query}%")
               .includes(:author, :category)
               .with_attached_imagem_capa_file
               .order(publicado_em: :desc),
        limit: 12
      )
    else
      @resultados = []
    end
  end
end
