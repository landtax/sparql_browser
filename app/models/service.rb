class Service < Resource::Base

  def self.facets_available
    ['task', 'language']
  end

  def related_available
    ['similar_services'] #ok
  end

  def self.find_all_query
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/>
SELECT distinct ?service_id ?service ?description
FROM <http://IulaClarinMetadata.edu>
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

  def find_all_similar_services
    query = <<EOF
prefix test: <http://gilmere.upf.edu/MetadataRecords.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
SELECT DISTINCT ?s_id ?s
FROM <http://IulaClarinMetadata.edu>
WHERE
{
 test:#{id} bio:task ?task .
 ?s_id bio:task ?task ; rdfs:label ?s .
}
EOF
   SolutionsBrowser.new( Resource::Base.query(query) )
  end

end
