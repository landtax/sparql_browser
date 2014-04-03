class Task < Resource::Base

  def priority_attr
    %w{Description}
  end

  def banned_attr
    %w{name type}
  end

  def self.facets_available
    ['project', 'service']
  end

  def self.find_all_query
    query = <<EOF
    #{namespaces}
SELECT distinct ?task_id ?task ?description
    #{from}
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
    #{namespaces}
SELECT ?task_id ?task ?description
    #{from}
WHERE { ?project dc:subject ?task_id ; rdf:type foaf:Project ; dc:description ?description .
?task_id rdf:type bio:Task ; rdfs:label ?task .}
GROUP BY ?task_id
EOF
  self.query(query)
  end

  def self.find_all_faceted_by_service
    query = <<EOF
    #{namespaces}
SELECT ?service_id ?service
    #{from}
WHERE { ?s bio:task ?service_id ; rdf:type bio:Service. ?service_id rdfs:label ?service .}
GROUP BY ?service_id ?service
EOF
  self.query(query)
  end

  def find_all_related_documentation
    query = <<EOF
    #{Resource::Base.namespaces}
SELECT distinct ?s_id ?s ?dlabel
    #{Resource::Base.from}
WHERE
{ ?s_id a ?document ; dc:subject bio:#{label} ; rdfs:label ?s .
 ?document rdfs:subClassOf ms:Document ; rdfs:label ?dlabel .
}
EOF
   SolutionsBrowser.new( Resource::Base.query(query) )
  end

  def find_all_related_services
    query = <<EOF
    #{Resource::Base.namespaces}
SELECT distinct ?s_id ?s
    #{Resource::Base.from}
WHERE
{
 ?s_id bio:task bio:#{label} ; rdfs:label ?s .
}
EOF
   SolutionsBrowser.new( Resource::Base.query(query) )
  end

end
