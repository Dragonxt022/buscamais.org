class SiteSetting < ApplicationRecord
  CHAVES = %w[
    site_titulo site_descricao site_url
    email_remetente email_nome email_rodape
    google_client_id google_client_secret
    stripe_publishable_key stripe_secret_key stripe_webhook_secret
    ads_ativo ads_publisher_id ads_slot_horizontal ads_slot_quadrado ads_slot_in_content ads_slot_vertical
  ].freeze

  validates :chave, presence: true, inclusion: { in: CHAVES }, uniqueness: true
  validates :valor, presence: true, if: -> { %w[site_titulo email_remetente].include?(chave) }

  def self.[](chave)
    Rails.cache.fetch("site_setting_#{chave}", expires_in: 10.minutes) do
      find_by(chave: chave)&.valor
    end
  end

  def self.[]=(chave, valor)
    Rails.cache.delete("site_setting_#{chave}")
    record = find_or_initialize_by(chave: chave)
    record.update!(valor: valor)
  end

  def self.todos
    CHAVES.index_with { |k| self[k] }
  end
end
