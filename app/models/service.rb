class Service < Resource::Base


  def self.find_all_by_facet(facet)
    normal_facet = facet.downcase
    return [] unless ['task', 'language'].include? normal_facet.downcase
    solutions = self.send(:"find_all_faceted_by_#{normal_facet}")
    SolutionsBrowser.new(solutions)
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
