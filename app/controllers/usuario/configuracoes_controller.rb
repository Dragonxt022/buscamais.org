class Usuario::ConfiguracoesController < Usuario::BaseController
  def edit
    @topicos_disponiveis = Category.ativas.order(:nome)
    @topicos_seguidos    = current_user.user_topics.pluck(:category_id)
  end

  def update
    if params[:category_ids].present?
      current_user.user_topics.destroy_all
      params[:category_ids].each do |cat_id|
        current_user.user_topics.create(category_id: cat_id)
      end
    end
    redirect_to usuario_configuracoes_path, notice: "Configurações salvas."
  end
end
