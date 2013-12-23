class Task < Resource::Base

  def self.find_all_by_facet(facet)
    normal_facet = facet.downcase
    return [] unless ['project', 'service'].include? normal_facet.downcase
    solutions = self.send(:"find_all_faceted_by_#{normal_facet}")
    SolutionsBrowser.new(solutions)
  end

  def self.find_all_faceted_by_project
    select = "?project ?task_id ?task  ?description"
    where = "?project dc:subject ?task_id ; rdf:type foaf:Project ; dc:description ?description .  ?task_id rdf:type bio:Task ; rdfs:label ?task ."
    group_by = "?task_id"

    self.query(self.construct_query select, where,  group_by)
  end

  def self.find_all_faceted_by_service
    select = "?service ?service_id ?task_id ?task "
    where = "?service_id bio:task ?p ; rdf:type bio:Service . ?task_id rdfs:label ?task ."
    group_by = "?task_id ?label"

    self.query(self.construct_query select, where, group_by)
  end

end
