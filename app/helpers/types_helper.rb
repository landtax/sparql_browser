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
      make_dbpedia_wikipedia_html_links label
    elsif label.match("^http://")
      link_to "#{label} <small><i class='icon-share'> </i></small>".html_safe, label, :target => "_blank", :title => "External link"
    elsif id.blank?
      label
    else
      link_to labelize(label), resource_path(id)
    end
  end

  def extract_dbpedia_label label
    #label.scan(/([-\w\(\)]+)$/)[0] || [""]).first
    uri = URI.parse(label)
    File.basename(uri.path)
  end

  def dbpedia_label label
    extract_dbpedia_label(label).humanize
  end

  def is_dbpedia? label
    label.match("^http://dbpedia.org")
  end

  def dbpedia_link_to_wiki_link label
    "http://en.wikipedia.org/wiki/" + extract_dbpedia_label(label)
  end

  def make_dbpedia_subjects_query label
    query = ""
    query << "http://dbpedia.org/sparql?default-graph-uri=http%3A%2F%2Fdbpedia.org&query=select+%3Fo+where+%7B+%3Chttp%3A%2F%2Fdbpedia.org%2Fresource%2F"
    query << extract_dbpedia_label(label)
    query << "%3E%09dcterms%3Asubject+%3Fo+.%7D&format=text%2Fhtml&timeout=30000&debug=on"    
    query
  end

  def dbpedia_subjects_link label
    link_to("Dbpedia subjects <small><i class='icon-share'> </i></small>".html_safe, make_dbpedia_subjects_query(label), :target => "_blank", :title => "External link")
  end

  def make_dbpedia_wikipedia_html_links label
    html = ""
    html << dbpedia_label(label)
    html << '&nbsp;&nbsp;&nbsp;'
    html << '<font size="-1">'
    html << link_to("[ DBpedia <small><i class='icon-share'> </i></small>".html_safe, label, :target => "_blank", :title => "External link")
    html << "&nbsp;&nbsp;"
    html << link_to("Wikipedia <small><i class='icon-share'> </i></small> ]".html_safe, dbpedia_link_to_wiki_link(label), :target => "_blank", :title => "External link")
    html << "</font>"
    html.html_safe
  end

  def dbpedia_subjects_insert_table label
    begin
      response = open( make_dbpedia_subjects_query label ).read
    rescue
      ""
    else
      
      # response.sub! 'class="sparql"', 'class="table table-hover table-condensed table-bordered"'
      # response.sub!(/<th>.*/, '')
      # response.gsub!(/<\/a>/, ' <small><i class="icon-share"> </i></small></a>')
      # response.html_safe

      html = ""
      links = response.scan(/href=".*?"/)
      links.each do |link|
        link.gsub!(/"/,'')
        link.gsub!(/href=/,'')
        html << make_dbpedia_wikipedia_html_links( link )
        html << '</br>'
      end 
      html.html_safe

    end
    
  end

end
