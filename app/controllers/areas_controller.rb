class AreasController < ApplicationController
  before_filter :find_type

  def show
    @facet = "area"
    @type_name = "Area"
    @type = target(@type_name)
    @type_description = @type.description_of @type_name

    @browser = @type.send(:find_all_by_facet, @facet)
    render :show_faceted
  end

  private

  def find_type
    @type_name = params[:id]
  end

  def target(type_name)
    case type_name.downcase
    when 'service'
      Service
    when 'task'
      Task
    when 'document'
      Document
    when 'corpus'
      Corpus
    when 'lexica'
      Lexica
    when 'project'
      Project
    when 'area'
      Area
    end
  end
end
