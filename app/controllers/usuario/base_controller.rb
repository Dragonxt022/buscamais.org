class Usuario::BaseController < ApplicationController
  before_action :authenticate_user!

  layout "usuario"
end
