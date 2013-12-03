class Service < Resource::Base

  def self.query_find_all
    select =  "?s ?slabel"
    where = "?s rdf:type bio:Service ; rdfs:label ?slabel ."

    self.construct_query(select, where, nil)
  end

  def self.query_find_by_id id
    select = "*"
    where = []
    where << "record:#{id} ?p ?o ."
    where << "?p rdfs:label ?plabel ."
    where << "optional { ?o rdfs:label ?olabel .} "
    self.construct_query(select, where.join(" \n"), nil)
  end

end
