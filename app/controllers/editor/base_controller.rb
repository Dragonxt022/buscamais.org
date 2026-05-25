class Editor::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :requer_editor!

  layout "admin"
end
