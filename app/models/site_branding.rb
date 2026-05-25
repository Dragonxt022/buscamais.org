class SiteBranding < ApplicationRecord
  has_one_attached :logo
  has_one_attached :favicon

  def self.instance
    first_or_create!
  end

  def logo_url
    return unless logo.attached?
    Rails.application.routes.url_helpers.rails_blob_path(logo.blob, only_path: true)
  end

  def favicon_url
    return unless favicon.attached?
    Rails.application.routes.url_helpers.rails_blob_path(favicon.blob, only_path: true)
  end
end
