class NotificationMailer < ApplicationMailer
  def comentario_aprovado(notification)
    @notification = notification
    @user         = notification.user
    @dados        = notification.dados_hash
    @site_titulo  = SiteSetting["site_titulo"].presence || "Busca Mais"
    @site_url     = SiteSetting["site_url"].presence || "http://localhost"

    mail(
      to:      @user.email,
      subject: "Seu comentário foi aprovado — #{@site_titulo}"
    )
  end

  def nova_resposta(notification)
    @notification = notification
    @user         = notification.user
    @dados        = notification.dados_hash
    @site_titulo  = SiteSetting["site_titulo"].presence || "Busca Mais"
    @site_url     = SiteSetting["site_url"].presence || "http://localhost"

    mail(
      to:      @user.email,
      subject: "#{@dados['autor']} respondeu seu comentário — #{@site_titulo}"
    )
  end

  def nova_curtida(notification)
    @notification = notification
    @user         = notification.user
    @dados        = notification.dados_hash
    @site_titulo  = SiteSetting["site_titulo"].presence || "Busca Mais"
    @site_url     = SiteSetting["site_url"].presence || "http://localhost"

    mail(
      to:      @user.email,
      subject: "#{@dados['autor']} curtiu seu comentário — #{@site_titulo}"
    )
  end
end
