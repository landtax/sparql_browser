class Area < Resource::Base

  def priority_attr
    %w{}
  end

  def banned_attr
    %w{}
  end

  def self.facets_available
    ["area"]
  end

  def related_available
    []
  end

  def self.find_all_query
    query = <<EOF
    #{namespaces}
SELECT ?area ?s_id ?s ?type
    #{from}
WHERE {?s_id ms:area ?area ; rdfs:label ?s ; rdf:type ?type .
FILTER(NOT(REGEX(STR(?type), "^http://www.w3.org/"))) . 
  }
GROUP BY ?area ORDER BY ?area
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_area

    select = "?area ?s_id ?s ?type"
    where = []
    where << "?s_id ms:area ?area ; rdfs:label ?s ; rdf:type ?type .  "
    where << 'FILTER(NOT(REGEX(STR(?type), "^http://www.w3.org/"))) . '

    group_by = "?area ORDER BY ?area"

    self.query(self.construct_query select, where.join("\n"), group_by)
  end

end
