class Project < Resource::Base

  def priority_attr
    %w{name homepage description area subject}
  end

  def banned_attr
    %w{type}
  end

  def self.facets_available
    ['task', 'area']
  end

  def self.find_all_query
    query = <<EOF
    #{namespaces}
    SELECT ?project_id ?project ?desc
    #{from}
    WHERE {
        ?project_id a foaf:Project ; dc:description ?desc ; rdfs:label ?project
    } ORDER BY ?project
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_task
    query = <<EOF
    #{namespaces}
SELECT ?subject_id ?subject ?project_id ?project ?desc
    #{from}
WHERE { ?project_id rdf:type foaf:Project ; dc:subject ?subject_id ; rdfs:label ?project; dc:description ?desc .
?subject_id rdfs:label ?subject .}
GROUP BY ?subject_id ORDER BY ?subject_id
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_area
    query = <<EOF
    #{namespaces}
SELECT ?area ?project_id ?project ?desc
    #{from}
WHERE { ?project_id rdf:type foaf:Project ; ms:area ?area ; rdfs:label ?project; dc:description ?desc .

FILTER (regex(str(?area),"http://dbpedia"))
}

ORDER BY ?area 
EOF

    self.query(query)
  end

end
