class ResourcesController < ApplicationController
  def index
    @resources = Service.find_all
  end

  def show
    @resource = Service.find_by_id params[:id]
    @priority_attr = ["Title", "resourceName", "Description", "languageName", "documentation"]
    @attributes = @resource.attr_list - @priority_attr
    @attributes.delete_if {|a| a == ""}
    @browser_related = @resource.other_using_this_resource
  end
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
