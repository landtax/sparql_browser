module ApplicationHelper

  def labelize(string)
    if is_dbpedia? string
      dbpedia_label(string)
    else
      back_to_case(string.camelize.titleize)
    end
  end

  def area_icon type
    if type.to_s.match(/Project/)
      klass = "icon-briefcase"
      title = "Project"
    else
      klass = "icon-book"
      title = "Document"
    end
    "<i class='#{klass}' title='#{title}'> #{title} </i>".html_safe
  end

  def back_to_case(text)

    result = text
    %w( Lmf Wsdl Rdf Owl Iula Xces Nlp Html Panacea Pdf Xml Txt Tgz Cqp Dcr).each do |i|
      result = result.gsub(Regexp.new("#{i}"), "#{i.upcase}")
    end
    {"Gr Af" => "GrAF",
     "Ms Word" => "MS Word",
     "Po S" => "PoS",
     "Tf Idf" => "TF-IDF"}.each do |i, j|
      result = result.gsub(Regexp.new("#{i}"), "#{j}")
    end
    result
  end

end


