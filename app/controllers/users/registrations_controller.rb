class Users::RegistrationsController < Devise::RegistrationsController
  invisible_captcha only: [:create], honeypot: :website

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nome])
  end

  before_action :configure_sign_up_params, only: [:create]
end
