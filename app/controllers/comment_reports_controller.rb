class CommentReportsController < ApplicationController
  before_action :authenticate_user!

  def create
    comment = Comment.aprovados.find(params[:comment_id])

    if comment.user == current_user
      respond_to do |f|
        f.json { render json: { error: "Você não pode denunciar seu próprio comentário." }, status: :unprocessable_entity }
        f.html { redirect_back_or_to "#", alert: "Você não pode denunciar seu próprio comentário." }
      end
      return
    end

    report = current_user.comment_reports.find_or_initialize_by(comment: comment)

    if report.persisted?
      respond_to do |f|
        f.json { render json: { error: "Você já denunciou este comentário." }, status: :unprocessable_entity }
        f.html { redirect_back_or_to "#", alert: "Você já denunciou este comentário." }
      end
      return
    end

    report.reason    = params[:reason].presence || "outro"
    report.descricao = params[:descricao].presence

    if report.save
      # Notifica admins se o comentário já tem múltiplas denúncias
      if comment.comment_reports.count >= 3
        Notification.notificar_admins_novo_comentario(comment) rescue nil
      end
      respond_to do |f|
        f.json { render json: { reported: true }, status: :created }
        f.html { redirect_back_or_to noticia_path(comment.article.slug, anchor: "comentario-#{comment.id}"),
                                     notice: "Comentário denunciado. Obrigado pela ajuda!" }
      end
    else
      respond_to do |f|
        f.json { render json: { error: report.errors.full_messages.join(", ") }, status: :unprocessable_entity }
        f.html { redirect_back_or_to "#", alert: report.errors.full_messages.join(", ") }
      end
    end
  end
end
