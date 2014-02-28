class TypesController < ApplicationController
  before_filter :find_type

  def show
    @type_name = params[:id]
    @type = target(@type_name)
    @type_description = @type.description_of @type_name

    @browser = @type.send(:find_all)
    render :show
  end

  def show_faceted

    @facet = params[:facet_id]
    @type = target(@type_name)
    @type_name = params[:id]

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
    end
  end
end
