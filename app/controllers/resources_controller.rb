class ResourcesController < ApplicationController
  def index
    @resources = Service.find_all
  end

  def show
    @resource = Service.find_by_id params[:id]
  end
end
