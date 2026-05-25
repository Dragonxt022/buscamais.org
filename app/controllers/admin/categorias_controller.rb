class Admin::CategoriasController < Admin::BaseController
  before_action :carregar_categoria, only: [:edit, :update, :destroy]

  def index
    @categorias = Category.order(:nome)
  end

  def new
    @categoria = Category.new
  end

  def create
    @categoria = Category.new(categoria_params)
    if @categoria.save
      redirect_to admin_categorias_path, notice: "Categoria criada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @categoria.update(categoria_params)
      redirect_to admin_categorias_path, notice: "Categoria atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @categoria.destroy
    redirect_to admin_categorias_path, notice: "Categoria removida."
  end

  def bulk_destroy
    ids = Array(params[:ids]).map(&:to_i)
    count = Category.where(id: ids).destroy_all.size
    redirect_to admin_categorias_path, notice: "#{count} categoria(s) removida(s)."
  end

  private

  def carregar_categoria
    @categoria = Category.find(params[:id])
  end

  def categoria_params
    params.require(:category).permit(:nome, :descricao, :cor, :ativo)
  end
end
