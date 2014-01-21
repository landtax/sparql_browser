class Service < Resource::Base


  def self.facets_available
    ['task', 'language']
  end

  def self.related_available
    ["related_documentation", "related_services"]
  end

  def self.find_all_query
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
SELECT distinct ?service_id ?service ?description
WHERE
{
 ?service_id rdf:type bio:Service ; 
rdfs:label ?service .
OPTIONAL { ?service_id dc:description ?description .}
}

EOF

    self.query(query)
  end

  def self.find_all_faceted_by_task

    select = "?task_id ?task ?service_id ?service ?description"
    where = []
    where << "?service_id bio:task ?task_id ; rdf:type bio:Service ; rdfs:label ?service ; dc:description ?description . "
    where << "?task_id rdfs:label ?task ."

    group_by = "?task_id ORDER BY ?task 2"

    self.query(self.construct_query select, where.join("\n"), group_by)
  end

  def self.find_all_faceted_by_language

    select = "?language ?service_id ?service ?description"
    where = "?service_id ms:languageName ?language ; rdfs:label ?service ; a bio:Service ; dc:description ?description ."
    group_by = "?language ORDER BY ?language"

    self.query(self.construct_query select, where, group_by)
  end

end
