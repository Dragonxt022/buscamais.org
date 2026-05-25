class PaginasController < ApplicationController
  def sobre; end
  def carreiras; end
  def privacidade; end
  def termos; end

  def contato; end

  def enviar_contato
    flash[:notice] = "Mensagem enviada com sucesso! Retornaremos em até 2 dias úteis."
    redirect_to contato_path
  end

  def boletim; end

  def assinar_boletim
    flash[:notice] = "Inscrição realizada! Em breve você receberá nossas novidades."
    redirect_to boletim_path
  end

  def mapa_site
    @categorias = Category.ativas.order(:nome)
    @artigos    = Article.publicados
                         .includes(:category)
                         .order(publicado_em: :desc)
                         .limit(200)
  end

  def sitemap
    @artigos    = Article.publicados.order(publicado_em: :desc)
    @categorias = Category.ativas.order(:nome)
    respond_to do |format|
      format.xml { render layout: false }
    end
  end
end
