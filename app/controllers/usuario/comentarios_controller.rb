class Usuario::ComentariosController < Usuario::BaseController

  def index
    @pagy, @comentarios = pagy(
      current_user.comments.includes(:article).order(created_at: :desc)
    )
  end
end
