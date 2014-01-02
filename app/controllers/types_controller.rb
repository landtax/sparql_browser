class TypesController < ApplicationController
  before_filter :find_type

  def show
    @browser = Resource::Base.find_by_type(@type)
  end

  def show_faceted
    @facet = params[:facet_id]

    case params[:id].downcase
    when 'service'
      target = Service
    when 'task'
      target = Task
    when 'document'
      target = Document
    when 'corpus'
      target = Corpus
    end

    @browser = target.send(:find_all_by_facet, @facet)
    render :show
  end

  private

  def find_type
    @type = params[:id]
  end
end
