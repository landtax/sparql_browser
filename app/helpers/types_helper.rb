module TypesHelper

  def facets_for_type(type, current_facet)
    options = {}
    type.facets_available.each { |f| options[optionize(f)] = facet_path(@type_name, f) }
    select_tag("facet",  options_for_select(options, facet_path(@type_name, current_facet)), :class => "form-control", :id => 'facet_selector')
  end

  def optionize(value)
    "by #{value.humanize}"
  end

  def link_or_value(label, id=nil)
    if label.match("^http://")
      link_to "#{label} <small><i class='icon-share'> </i></small>".html_safe, label, :target => "_blank", :title => "External link"
    elsif id.blank?
      label
    else
      link_to labelize(label), resource_path(id)
    end
  end

end
