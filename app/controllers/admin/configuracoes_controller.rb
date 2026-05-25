class Admin::ConfiguracoesController < Admin::BaseController
  def show
    @configuracoes = SiteSetting.todos
    @branding      = SiteBranding.instance
  end

  def update
    # Salva configurações de texto
    SiteSetting::CHAVES.each do |chave|
      valor = params.dig(:site_setting, chave)
      next if valor.nil?
      if valor.blank? && !%w[site_titulo email_remetente].include?(chave)
        SiteSetting.find_by(chave: chave)&.destroy
        Rails.cache.delete("site_setting_#{chave}")
      else
        SiteSetting[chave] = valor unless valor.blank?
      end
    end

    # Salva identidade visual (logo e favicon via ActiveStorage)
    branding = SiteBranding.instance
    branding.logo.attach(params[:branding_logo])       if params[:branding_logo].present?
    branding.favicon.attach(params[:branding_favicon]) if params[:branding_favicon].present?
    branding.logo.purge   if params[:remover_logo] == "1"
    branding.favicon.purge if params[:remover_favicon] == "1"

    redirect_to admin_configuracoes_path, notice: "Configurações salvas com sucesso."
  end
end
