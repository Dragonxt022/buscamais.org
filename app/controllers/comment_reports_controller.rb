class CommentReportsController < ApplicationController
  before_action :authenticate_user!

  def create
    comment = Comment.aprovados.find(params[:id])

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
      # Notifica admins na primeira denúncia e a cada 5
      count = comment.comment_reports.count
      if count == 1 || count % 5 == 0
        User.where(role: :administrador).find_each do |admin|
          Notification.create!(
            user:        admin,
            notificable: comment,
            tipo:        "novo_comentario",
            dados:       {
              autor:   comment.user.nome,
              artigo:  comment.article.titulo,
              slug:    comment.article.slug,
              extra:   "⚑ #{count} denúncia(s)"
            }.to_json
          ) rescue nil
        end
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
