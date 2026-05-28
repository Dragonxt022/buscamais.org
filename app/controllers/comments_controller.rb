class CommentsController < ApplicationController
  before_action :authenticate_user!

  DELAY_ENTRE_COMENTARIOS = 60 # segundos

  def create
    @artigo  = Article.publicados.friendly.find(params[:article_id])

    # Verifica delay entre comentários
    if current_user.tem_delay_entre_comentarios?
      ultimo = current_user.comments.order(created_at: :desc).first
      if ultimo && ultimo.created_at > DELAY_ENTRE_COMENTARIOS.seconds.ago
        espera = (DELAY_ENTRE_COMENTARIOS - (Time.current - ultimo.created_at)).ceil
        redirect_to noticia_path(@artigo.slug, anchor: "secao-comentarios"),
                    alert: "Aguarde #{espera} segundo(s) antes de comentar novamente. Assine o Plus para comentar sem restrições."
        return
      end
    end

    @comment = @artigo.comments.build(comment_params)
    @comment.user   = current_user
    @comment.status = current_user.comentarios_com_moderacao? ? :pendente : :aprovado

    if @comment.save
      Notification.notificar_admins_novo_comentario(@comment)
      Notification.notificar_resposta(@comment) if @comment.parent_id?
      if @comment.aprovado?
        # Ancora no comentário recém-criado para manter o usuário na seção
        anchor = @comment.parent_id? ? "comentario-#{@comment.parent_id}" : "comentario-#{@comment.id}"
        redirect_to noticia_path(@artigo.slug, anchor: anchor),
                    notice: "Comentário publicado."
      else
        redirect_to noticia_path(@artigo.slug, anchor: "secao-comentarios"),
                    flash: { comentario_pendente: true }
      end
    else
      redirect_to noticia_path(@artigo.slug, anchor: "secao-comentarios"),
                  alert: @comment.errors.full_messages.join(", ")
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:conteudo, :parent_id)
  end
end
