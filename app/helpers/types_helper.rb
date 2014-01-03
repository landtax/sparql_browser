module TypesHelper

  def facets_for_type(type, current_facet)
    options = {}
    type.facets_available.each { |f| options[optionize(f)] = facet_path(@type_name, f) }
    select_tag("facet",  options_for_select(options, facet_path(@type_name, current_facet)), :class => "form-control", :id => 'facet_selector')
  end

  def optionize(value)
    "by #{value.humanize}"
  end
end
