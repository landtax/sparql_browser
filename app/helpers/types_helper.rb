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
    if is_dbpedia? label
      link_to "#{dbpedia_label(label)} <small><i class='icon-share'> </i></small>".html_safe, label, :target => "_blank", :title => "External link"
    elsif label.match("^http://")
      link_to "#{label} <small><i class='icon-share'> </i></small>".html_safe, label, :target => "_blank", :title => "External link"
    elsif id.blank?
      label
    else
      link_to labelize(label), resource_path(id)
    end
  end

  def dbpedia_label label
    extracted_label = (label.scan(/([\w\(\)]+)$/)[0] || [""]).first
    extracted_label.humanize
  end

  def is_dbpedia? label
    label.match("^http://dbpedia.org")
  end

end
