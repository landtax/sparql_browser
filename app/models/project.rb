class Project < Resource::Base

  def self.facets_available
    ['task', 'topic']
  end

  def self.find_all_query
    query = <<EOF
    #{namespaces}
    SELECT ?project_id ?project ?desc
    #{from}
    WHERE {
        ?project_id a foaf:Project ; dc:description ?desc ; rdfs:label ?project
    }
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

  def self.find_all_faceted_by_topic
    query = <<EOF
    #{namespaces}
SELECT ?subject ?project_id ?project ?desc
    #{from}
WHERE { ?project_id rdf:type foaf:Project ; dc:subject ?subject ; rdfs:label ?project; dc:description ?desc .

FILTER (regex(str(?subject),"http://dbpedia"))
}

ORDER BY ?subject 
EOF

    self.query(query)
  end

end
