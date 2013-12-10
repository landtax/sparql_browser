class Service < Resource::Base

  def self.query_find_all
    select =  "?s ?slabel"
    where = "?s rdf:type bio:Service ; rdfs:label ?slabel ."

    self.construct_query(select, where, nil)
  end

  def self.query_find_by_id id
    select = "*"
    where = []
    where << "{ record:#{id} ?p ?o ."
    where << "optional { ?p rdfs:label ?plabel . }"
    where << "optional { ?o rdfs:label ?olabel . } "
    where << "} UNION "
    where << "{ bio:#{id} ?p ?o ."
    where << "optional { ?p rdfs:label ?plabel . }"
    where << "optional { ?o rdfs:label ?olabel . } "
    where << "}"
    self.construct_query(select, where.join(" \n"), nil)
  end

end
