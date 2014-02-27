class ResourcesController < ApplicationController
  def index
    @resources = Resource::Base.find_all
  end

  def show
    @resource = Resource::Base.find_by_id params[:id]
    @priority_attr = ["Title", "resourceName", "Description", "languageName", "documentation"]
    @attributes = @resource.attr_list - @priority_attr
    @attributes.delete_if {|a| a == ""}
    @browser_other_using = @resource.other_using_this_resource
    @browser_related = @resource.find_all_related
    @query = Resource::Base.query_find_by_id(params[:id])
  end

  private

end
#["",
 #"resourceName",
 #"characterEncoding",
 #"conformanceToStandardsBestPractices",
 #"contactPerson",
 #"creationMode",
 #"domain",
 #"encodingLevel",
 #"fundingProject",
 #"identifier",
 #"lexical Conceptual Resource Type",
 #"linguality",
 #"linguistic information",
 #"metaShareId",
 #"mimeType",
 #"originalSource",
 #"resourceCreator",
 #"resourceShortName",
 #"sizeInfo",
 #"url",
 #"mediaType",
 #"languageId",
 #"Description"]
