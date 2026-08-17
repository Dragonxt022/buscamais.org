class PaginasController < ApplicationController
  def sobre; end
  def carreiras; end
  def privacidade; end
  def termos; end
  def politica_editorial; end
  def correcoes; end

  def contato; end

  def enviar_contato
    msg = ContactMessage.new(
      nome:     params[:nome],
      email:    params[:email],
      assunto:  params[:assunto],
      mensagem: params[:mensagem]
    )
    if msg.save
      flash[:notice] = "Mensagem enviada com sucesso! Retornaremos em até 2 dias úteis."
    else
      flash[:alert] = "Preencha todos os campos obrigatórios."
    end
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
    @categorias = Category.ativas.com_artigos_publicados.order(:nome)
    @autores    = User.pode_publicar.where.not(slug: nil)
    respond_to do |format|
      format.xml { render layout: false }
    end
  end
end
