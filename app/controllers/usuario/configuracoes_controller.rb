class Usuario::ConfiguracoesController < Usuario::BaseController
  def edit
    @topicos_disponiveis = Category.ativas.order(:nome)
    @topicos_seguidos    = current_user.user_topics.pluck(:category_id)
  end

  def update
    ids = Array(params[:category_ids]).map(&:to_i).select(&:positive?)
    current_user.user_topics.destroy_all
    ids.each { |cat_id| current_user.user_topics.create(category_id: cat_id) }
    redirect_to usuario_configuracoes_path, notice: "Preferências salvas."
  end
end
