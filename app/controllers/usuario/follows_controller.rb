class Usuario::FollowsController < Usuario::BaseController
  def create
    followable = followable_from_params
    return head(:unprocessable_entity) unless followable
    return head(:forbidden) unless current_user.pode_seguir?

    current_user.user_follows.find_or_create_by!(followable: followable)
    redirect_back_or_to root_path, notice: "Você está seguindo #{followable_name(followable)}."
  end

  def destroy
    followable = followable_from_params
    follow = current_user.user_follows.find_by(followable: followable)
    follow&.destroy
    redirect_back_or_to root_path, notice: "Você deixou de seguir #{followable_name(followable)}."
  end

  private

  FOLLOWABLE_CLASSES = { "User" => User, "Category" => Category }.freeze

  def followable_from_params
    type  = params[:followable_type]
    id    = params[:followable_id]
    klass = FOLLOWABLE_CLASSES[type]
    return nil unless klass
    klass.find_by(id: id)
  end

  def followable_name(obj)
    obj.respond_to?(:nome) ? obj.nome : obj.to_s
  end
end
