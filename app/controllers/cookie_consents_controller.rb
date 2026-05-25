class CookieConsentsController < ApplicationController
  skip_after_action :verify_authorized, raise: false

  def create
    value = params[:consent] == "accepted" ? "accepted" : "rejected"
    cookies[:cookie_consent] = {
      value:     value,
      expires:   1.year.from_now,
      same_site: :lax,
      path:      "/"
    }
    head :no_content
  end
end
