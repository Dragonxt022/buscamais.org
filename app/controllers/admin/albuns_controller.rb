class Admin::AlbunsController < Admin::BaseController
  before_action :set_album, only: [:edit, :update, :destroy]

  def index
    @albuns = Album.ordenados.includes(:capa, :media_files)
  end

  def new
    @album = Album.new
  end

  def create
    @album = Album.new(album_params.merge(user: current_user))
    if @album.save
      redirect_to admin_albuns_path, notice: "Álbum \"#{@album.nome}\" criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @album.update(album_params)
      redirect_to admin_albuns_path, notice: "Álbum \"#{@album.nome}\" salvo com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    nome = @album.nome
    @album.destroy
    redirect_to admin_albuns_path, notice: "Álbum \"#{nome}\" removido. As imagens continuam disponíveis, sem álbum."
  end

  private

  def set_album
    @album = Album.find(params[:id])
  end

  def album_params
    params.require(:album).permit(:nome, :descricao, :capa_media_file_id)
  end
end
