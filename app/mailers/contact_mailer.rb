class ContactMailer < ApplicationMailer
  def resposta(mensagem)
    @mensagem = mensagem
    mail(
      to:      "#{mensagem.nome} <#{mensagem.email}>",
      subject: "Re: #{mensagem.assunto_label} — #{SiteSetting['site_titulo'].presence || 'Busca Mais'}"
    )
  end
end
