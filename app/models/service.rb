class Service < Resource::Base

  def self.query_find_all
    select =  "?s ?slabel"
    where = "?s rdf:type bio:Service ; rdfs:label ?slabel ."

    self.construct_query(select, where, nil)
  end


end
