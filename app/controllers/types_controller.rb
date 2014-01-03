class TypesController < ApplicationController
  before_filter :find_type

  def show
    @browser = Resource::Base.find_by_type(@type)
  end

  def show_faceted
    @facet = params[:facet_id]

    @type = case params[:id].downcase
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

    @browser = @type.send(:find_all_by_facet, @facet)
    render :show
  end

  private

  def find_type
    @type_name = params[:id]
  end
end
