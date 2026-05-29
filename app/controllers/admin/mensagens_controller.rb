class Admin::MensagensController < Admin::BaseController

  before_action :carregar_mensagem, only: [:show, :responder]

  def index
    scope = ContactMessage.recentes
    scope = scope.nao_lidas    if params[:filtro] == "nao_lidas"
    scope = scope.where(respondida: false) if params[:filtro] == "pendentes"
    @pagy, @mensagens = pagy(scope, limit: 20)
  end

  def show
    @mensagem.marcar_lida!
  end

  def responder
    if params[:resposta].blank?
      redirect_to admin_mensagen_path(@mensagem), alert: "A resposta não pode estar vazia."
      return
    end

    @mensagem.update!(
      resposta:      params[:resposta],
      respondida:    true,
      respondida_em: Time.current
    )

    ContactMailer.resposta(@mensagem).deliver_later

    redirect_to admin_mensagen_path(@mensagem), notice: "Resposta enviada para #{@mensagem.email}."
  end

  private

  def carregar_mensagem
    @mensagem = ContactMessage.find(params[:id])
  end
end
