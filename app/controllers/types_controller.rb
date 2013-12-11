class TypesController < ApplicationController
  def show
    @resources = Resource::Base.find_by_type(params[:id])
  end
end
