require 'ostruct'

class Resource::Base
  attr_accessor :id, :label, :type, :type_id, :attributes
  attr_accessor :attr_list
  cattr_accessor :descriptions

  def initialize(id, label, type, type_id, attributes)
    self.id = id
    self.label = label
    self.type = type
    self.type_id = type_id

    initialize_attributes(attributes)
  end

  def priority_attr
    ["Title", "resourceName", "Description", "languageName", "documentation"]
  end

  def banned_attr
    []
  end

  def non_priority_attr
    attr_list - priority_attr - banned_attr - [""]
  end

  def self.find_all_by_facet(facet)
    normal_facet = facet.downcase
    return [] unless facets_available.include? normal_facet.downcase
    solutions = self.send(:"find_all_faceted_by_#{normal_facet}")
    SolutionsBrowser.new(solutions)
  end

  def self.find_all
    SolutionsBrowser.new(self.find_all_query)
  end

  def self.fetch_descriptions
    query = <<EOF
    #{namespaces}
SELECT ?s ?label ?description
    #{from}
WHERE {?s dc:description ?description ; rdfs:label ?label .
}
EOF
    Resource::Base.query(query)
  end

  def self.description_of(id)
    all_descriptions = $sparql_cache.fetch('descriptions') do
      descriptions = {}
      self.fetch_descriptions.each do |r|
        res_id = r[:s].to_s.split("#")[1]
        descriptions[res_id] = r[:description].to_s
      end
      descriptions
    end

    all_descriptions[id.to_s]
  end

  def initialize_attributes(atts)
    hash = {}
    atts.each do |att|
      key = att.type

      if hash.keys.include?(key)
        unless hash[key].kind_of?(Array)
          hash[key] = [hash[key]]
        end
        hash[key] << att
      else
        hash[key] = att
      end
    end

    self.attr_list = hash.keys
    self.attributes = OpenStruct.new(hash)
  end

  def self.sorted_attr_list
    attr_list
  end

  def self.find_by_type(type)
    solutions = query query_find_by_type(type)
    SolutionsBrowser.new(solutions)
  end

  def self.find_by_id id
    self.build id, query(query_find_by_id(id))
  end

  def self.build_list(solutions)
    solutions.map do |s|
      id = s[:o].to_s.split("#")[1]
      label = s[:olabel].to_s
      description = Resource::Base.new(nil, s[:description].to_s, "description", nil, [])
      Resource::Base.new(id, label, nil, nil, [description] )
    end
  end

  def self.build_owl_attribute(solution)
    type = solution[:p].to_s.scan(/owl#(.*$)/).flatten[0]
    label = solution[:o].to_s
    id = nil
    type_id = nil

    Resource::Base.new(id, label, type, type_id, [])
  end

  def self.build_attribute(solution)
    label = ""

    if solution_is_resource?(solution)
      id = solution[:o].to_s.split("#")[1]
      label = solution[:olabel].to_s
    else
      label = solution[:o].to_s
    end

    type = solution[:plabel].to_s
    type_id = solution[:p].to_s

    Resource::Base.new(id, label, type, type_id, [])
  end

  def self.build(id, solutions)
    attributes = []
    label = ""
    type = ""
    type_id = ""

    solutions.each_solution do |solution|
      if solution_is_label?(solution)
        label = solution[:o].to_s
      elsif solution_is_type?(solution)
        type = solution[:olabel].to_s
        type_id = solution[:o].to_s
      elsif solution_is_owl?(solution)
        attributes << build_owl_attribute(solution)
      else
        attributes << build_attribute(solution)
      end
    end

    Resource::Factory.build(id, label, type, type_id, attributes)
  end

  def other_using_this_resource
    query = <<EOF
    #{Resource::Base.namespaces}
 SELECT *
    #{Resource::Base.from}
 {
  {
  SELECT ?mss as ?s_id ?msslabel as ?s ?mstype AS ?type_id ?mstypelabel AS ?type
   WHERE {?mss ?p ms:#{id} ; rdfs:label ?msslabel ; rdf:type ?mstype .
   ?mstype rdfs:label ?mstypelabel
  }
 }
 UNION
 {
    SELECT ?bios as ?s_id ?bioslabel as ?s ?biotype AS ?type_id ?biotypelabel AS ?type
    WHERE {?bios ?biop bio:#{id} ;rdfs:label ?bioslabel ; rdf:type ?biotype .
    ?biotype rdfs:label ?biotypelabel .}
 }
 UNION
 {
    SELECT ?bios as ?s_id ?bioslabel as ?s ?biotype AS ?type_id ?biotypelabel AS ?type
    WHERE {?bios ?biop test:#{id} ;rdfs:label ?bioslabel ; rdf:type ?biotype .
    ?biotype rdfs:label ?biotypelabel .}
 }
 }
EOF

    SolutionsBrowser.new( Resource::Base.query(query) )
  end


  def self.query_find_by_id id
    select = "*"
    where = []
    where << "{ test:#{id} ?p ?o ."
    where << "optional { ?p rdfs:label ?plabel . }"
    where << "optional { ?o rdfs:label ?olabel . } "
    where << "} UNION "
    where << "{ bio:#{id} ?p ?o ."
    where << "optional { ?p rdfs:label ?plabel . }"
    where << "optional { ?o rdfs:label ?olabel . } "
    where << "} UNION "
    where << "{ ms:#{id} ?p ?o ."
    where << "optional { ?p rdfs:label ?plabel . }"
    where << "optional { ?o rdfs:label ?olabel . } "
    where << "}"
    self.construct_query(select, where.join(" \n"), nil)
  end

  def related_available
    #overwritten by children when needed
    []
  end

  def find_all_related
    lists = {}
    related_available.each do |r|
      lists[r] = send(:"find_all_#{r}")
    end
    lists
  end

  def self.query_find_by_type(type)
    select =  "distinct ?label_id ?label ?description"
    where = ["?label_id rdf:type bio:#{type} ; rdfs:label ?label ."]
    where << "OPTIONAL { ?label_id dc:description ?description .}"

    self.construct_query(select, where.join(" \n"), nil)
  end

  def self.query(query)
    Rails.logger.debug(query)
    $sparql.query(query)
  end


  def self.construct_query select, where, group_by
    prefix = namespaces
    select =  "SELECT #{select}"
    where =   "WHERE {\n #{where} \n}"
    group_by = "GROUP BY #{group_by}" if group_by

    [prefix, select, self.from, where, group_by].join("\n")
  end


  def self.from
   "
      FROM <http://IulaClarinMetadata.edu>
   "
  end

  def self.namespaces
   "
    prefix ms: <http://purl.org/ms-lod/MetaShare.ttl#>
    prefix bio: <http://purl.org/ms-lod/BioServices.ttl#>
    prefix dc:  <http://purl.org/dc/elements/1.1/>
    prefix test: <http://purl.org/ms-lod/UPF-MetadataRecords.ttl#>
    prefix foaf:    <http://xmlns.com/foaf/0.1/>
    prefix browser: <http://browser.upf/browser#>
   "
  end

  protected


  def self.solution_is_resource?(solution)
    !solution[:olabel].to_s.empty?
  end

  def self.solution_is_label?(solution)
    solution[:p].to_s.match(/rdf-schema#label/) &&
      solution[:plabel].to_s.empty?
  end

  def self.solution_is_type?(solution)
    solution[:p].to_s.match(/22-rdf-syntax-ns#type/) &&
      !solution[:olabel].to_s.empty? &&
      ( solution[:o].to_s.match(/bio\.ttl#/) || solution[:o].to_s.match(/bibo\/#/) )
  end

  def self.solution_is_owl?(solution)
    solution[:p].to_s.match(/www.w3.org\/2002\/07\/owl/)
  end


end
