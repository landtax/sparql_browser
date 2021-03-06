class ResourcesController < ApplicationController
  layout 'resource'

  def index
    @resources = Resource::Base.find_all
  end

  def show
    @resource = Resource::Base.find_by_id params[:id]
    @priority_attributes = @resource.priority_attr
    @non_priority_attributes = @resource.non_priority_attr
    @browser_other_using = @resource.other_using_this_resource
    @browser_related = @resource.find_all_related
    @query = Resource::Base.query_find_by_id(params[:id])
  end

end
