class Admin::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_administrator!
end
