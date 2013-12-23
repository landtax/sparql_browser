class TypesController < ApplicationController
  before_filter :find_type

  def show
    @browser = Resource::Base.find_by_type(@type)
  end

  def show_faceted
    @resources = Resource::Base.find_by_type_and_facet(@type, params[:facet_id])
    @facet = params[:facet_id]

    case params[:facet_id].downcase
    when 'service'
      target = Service
    when 'task'
      target = Task
    end

    @solutions = target.send(:find_all_by_facet, @facet)
  end

  private

  def find_type
    @type = params[:id]
  end
end
