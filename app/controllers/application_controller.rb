class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :configurar_pagy
  before_action :carregar_categorias_menu

  rescue_from Pundit::NotAuthorizedError, with: :acesso_negado

  def after_sign_in_path_for(resource)
    case resource.role
    when "administrador" then admin_root_path
    when "editor"        then editor_root_path
    else                      usuario_root_path
    end
  end

  def after_sign_out_path_for(_resource)
    root_path
  end

  private

  def acesso_negado
    flash[:alert] = "Você não tem permissão para realizar esta ação."
    redirect_back_or_to root_path
  end

  def configurar_pagy
    @pagy_locale = "pt-BR"
  end

  def carregar_categorias_menu
    categorias = Category.ativas.order(:nome)
    artigos_por_categoria = Article.publicados
                                   .with_attached_imagem_capa_file
                                   .where(category: categorias)
                                   .order(publicado_em: :desc)
                                   .select(:id, :titulo, :slug, :category_id, :publicado_em)
                                   .group_by(&:category_id)

    @categorias_menu = categorias.map do |cat|
      { categoria: cat, artigos: (artigos_por_categoria[cat.id] || []).first(4) }
    end
  rescue
    @categorias_menu = []
  end

  def requer_admin!
    unless current_user&.administrador?
      acesso_negado
    end
  end

  def requer_editor!
    unless current_user&.editor? || current_user&.administrador?
      acesso_negado
    end
  end
end
