class Editor::AlbunsController < Editor::BaseController
  before_action :set_album, only: [:edit, :update, :destroy]

  def index
    authorize Album, :index?
    @albuns = Album.ordenados.includes(:capa, :media_files)
  end

  def new
    authorize Album, :create?
    @album = Album.new
  end

  def create
    authorize Album, :create?
    @album = Album.new(album_params.merge(user: current_user))
    if @album.save
      redirect_to editor_albuns_path, notice: "Álbum \"#{@album.nome}\" criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @album, :update?
  end

  def update
    authorize @album, :update?
    if @album.update(album_params)
      redirect_to editor_albuns_path, notice: "Álbum \"#{@album.nome}\" salvo com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @album, :destroy?
    nome = @album.nome
    @album.destroy
    redirect_to editor_albuns_path, notice: "Álbum \"#{nome}\" removido. As imagens continuam disponíveis, sem álbum."
  end

  private

  def set_album
    @album = Album.find(params[:id])
  end

  def album_params
    params.require(:album).permit(:nome, :descricao, :capa_media_file_id)
  end
end
