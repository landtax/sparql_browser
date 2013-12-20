class Service < Resource::Base


  def self.find_all_by_facet(facet)
    normal_facet = facet.downcase
    return [] if ['task', 'language'].include? normal_facet.downcase
    self.send(:"find_all_faceted_by_#{normal_facet}")
  end

  def self.find_all_faceted_by_task
    select = "*"
    where = []
    where << "?s bio:task ?t ; rdf:type bio:Service ; rdfs:label ?slabel ; dc:description ?description . "
    where << "?t rdfs:label ?tlabel ."

    group_by = "?t ORDER BY ?tlabel 2"

    self.query self.construct_query select, where.join("\n"), group_by
  end

  def self.find_all_faceted_by_language

    select = "*"
    where = []
    where << "a bio:Service . "
    where << "?s ms:languageName ?lang ;"
    where << "rdfs:label ?slabel ;"

    group_by = "GROUP BY ?lang ORDER BY ?lang"

    self.query self.construct_query select, where.join("\n"), group_by
  end

end
