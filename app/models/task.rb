class Task < Resource::Base

  def self.facets_available
    ['project', 'service']
  end

  def self.find_all_query
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
SELECT distinct ?task_id ?task ?description
WHERE
{
 ?task_id rdf:type bio:Task ; 
rdfs:label ?task .
OPTIONAL { ?task_id dc:description ?description .}
}

EOF

    self.query(query)


  end

  def self.find_all_faceted_by_project
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/>
prefix foaf:    <http://xmlns.com/foaf/0.1/#> 
SELECT ?project_id ?task_id ?task ?description
WHERE { ?project dc:subject ?task_id ; rdf:type foaf:Project ; dc:description ?description .
?task_id rdf:type bio:Task ; rdfs:label ?task .}
GROUP BY ?task_id

EOF
  self.query(query)
  end

  def self.find_all_faceted_by_service
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/#>
SELECT ?service_id ?service 
WHERE { ?s bio:task ?service_id ; rdf:type bio:Service. ?service_id rdfs:label ?service .}
GROUP BY ?service_id ?service

EOF
  self.query(query)
  end

end
