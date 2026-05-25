class Admin::ConfiguracoesController < Admin::BaseController
  def show
    @configuracoes = SiteSetting.todos
  end

  def update
    SiteSetting::CHAVES.each do |chave|
      valor = params.dig(:site_setting, chave)
      next if valor.nil?
      if valor.blank? && !%w[site_titulo email_remetente].include?(chave)
        existing = SiteSetting.find_by(chave: chave)
        existing&.destroy
        Rails.cache.delete("site_setting_#{chave}")
      else
        SiteSetting[chave] = valor unless valor.blank?
      end
    end

    redirect_to admin_configuracoes_path, notice: "Configurações salvas com sucesso."
  end
end
