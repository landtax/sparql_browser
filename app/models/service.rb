class Service < Resource::Base

  def priority_attr
    %w{resourceName description task documentation demoInvocation input output languageName serviceProvider contact fundingProject serviceTechnology endpoint WSDL}
  end

  def banned_attr
    %w{name type languageCode}
  end

  def self.facets_available
    ['task', 'language']
  end

  def related_available
    ['similar_services']
  end

  def self.find_all_query
    query = <<EOF
    #{namespaces}
SELECT distinct ?service_id ?service ?description
    #{from}
WHERE
{
 ?service_id rdf:type bio:Service ;
rdfs:label ?service .
OPTIONAL { ?service_id dc:description ?description .}
} ORDER BY ?service
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
    #{Resource::Base.namespaces}
SELECT ?s_id ?s
    #{Resource::Base.from}
WHERE
{
 test:#{id} bio:task ?task .
 ?s_id bio:task ?task ; rdfs:label ?s .
}
EOF
   SolutionsBrowser.new( Resource::Base.query(query) )
  end

end
