class Admin::AnunciosController < Admin::BaseController
  before_action :set_anuncio, only: [:edit, :update, :destroy]

  def index
    @anuncios = Advertisement.includes(imagem_attachment: :blob).order(created_at: :desc)
  end

  def new
    @anuncio = Advertisement.new
  end

  def create
    @anuncio = Advertisement.new(anuncio_params.merge(user: current_user))
    if @anuncio.save
      redirect_to admin_anuncios_path, notice: "Anúncio \"#{@anuncio.titulo}\" criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @anuncio.update(anuncio_params)
      redirect_to admin_anuncios_path, notice: "Anúncio \"#{@anuncio.titulo}\" salvo com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    titulo = @anuncio.titulo
    @anuncio.destroy
    redirect_to admin_anuncios_path, notice: "Anúncio \"#{titulo}\" removido."
  end

  private

  def set_anuncio
    @anuncio = Advertisement.find(params[:id])
  end

  def anuncio_params
    params.require(:advertisement).permit(:titulo, :url_destino, :formato, :ativo, :inicio_em, :fim_em, :imagem)
  end
end
