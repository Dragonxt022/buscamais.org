class AnuncioCliquesController < ApplicationController
  def show
    anuncio = Advertisement.find(params[:id])
    anuncio.registrar_clique!
    redirect_to anuncio.url_destino, allow_other_host: true
  end
end
