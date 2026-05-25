class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :requer_admin!

  layout "admin"
end
