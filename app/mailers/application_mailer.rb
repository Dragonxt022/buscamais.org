class ApplicationMailer < ActionMailer::Base
  default from: -> {
    nome    = SiteSetting["email_nome"].presence || "Busca Mais"
    address = SiteSetting["email_remetente"].presence || "noreply@buscamais.org"
    "#{nome} <#{address}>"
  }
  layout "mailer"
end
