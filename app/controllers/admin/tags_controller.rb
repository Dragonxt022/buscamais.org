class Admin::TagsController < Admin::BaseController
  before_action :carregar_tag, only: [:show, :edit, :update, :destroy]

  def index
    scope = Tag.order(:nome)
    scope = scope.where("nome LIKE ?", "%#{params[:q]}%") if params[:q].present?
    @pagy, @tags = pagy(scope)
  end

  def show; end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      redirect_to admin_tags_path, notice: "Tag criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @tag.update(tag_params)
      redirect_to admin_tags_path, notice: "Tag atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tag.destroy
    redirect_to admin_tags_path, notice: "Tag removida."
  end

  def bulk_destroy
    ids = Array(params[:ids]).map(&:to_i)
    count = Tag.where(id: ids).destroy_all.size
    redirect_to admin_tags_path, notice: "#{count} tag(s) removida(s)."
  end

  private

  def carregar_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:nome)
  end
end
