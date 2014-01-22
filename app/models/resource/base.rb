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

  def self.find_all_by_facet(facet)
    normal_facet = facet.downcase
    return [] unless facets_available.include? normal_facet.downcase
    solutions = self.send(:"find_all_faceted_by_#{normal_facet}")
    SolutionsBrowser.new(solutions)
  end

  def self.find_all
    SolutionsBrowser.new(self.find_all_query)
  end

  def self.description_of(id)
    return self.descriptions unless self.descriptions.nil?
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/>

SELECT ?s ?label ?description
FROM <http://IulaClarinMetadata.edu>
WHERE {?s dc:description ?description ; rdfs:label ?label .
}
EOF
    Rails.logger.debug(query)
    result = $sparql.query(query)
  
    self.descriptions = {}
    result.each do |r|
      res_id = r[:s].to_s.split("#")[1]
      self.descriptions[res_id] = r[:description].to_s
    end

    self.descriptions[id.to_s]
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
    build id, query(query_find_by_id(id))
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

    Resource::Base.new(id, label, type, type_id, attributes)
  end

  def self.query_description
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/#>

SELECT ?description
WHERE {ms:Corpus dc:description ?description .}

EOF

    Rails.logger.debug(query)
    result = $sparql.query(query)
    SolutionsBrowser.new(result).solutions.first[:description].to_s
  end

  def other_using_this_resource
    query = <<EOF

prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/#>

SELECT * {
{
SELECT ?mss as ?s_id ?msslabel as ?s ?mstype AS ?type_id ?mstypelabel AS ?type

FROM <http://IulaClarinMetadata.edu>
WHERE {?mss ?p ms:NamedEntityRecognition ; rdfs:label ?msslabel ; rdf:type ?mstype .
?mstype rdfs:label ?mstypelabel
}
} 
UNION 
{
SELECT ?bios as ?s_id ?bioslabel as ?s ?biotype AS ?type_id ?biotypelabel AS ?type 
FROM <http://IulaClarinMetadata.edu>
WHERE {?bios ?biop bio:NamedEntityRecognition ;rdfs:label ?bioslabel ; rdf:type ?biotype .
?biotype rdfs:label ?biotypelabel .}
}
}
EOF

    Rails.logger.debug(query)
    result = $sparql.query(query)
    SolutionsBrowser.new(result)
  end



  protected


  def self.query_find_by_id id
    select = "*"
    where = []
    where << "{ record:#{id} ?p ?o ."
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

    prefix = ["prefix ms: <http://gilmere.upf.edu/ms.ttl#>"]
    prefix << "prefix bio: <http://gilmere.upf.edu/bio.ttl#>"
    prefix << "prefix record: <http://gilmere.upf.edu/MetadataRecords.ttl#>"
    prefix << "prefix dc: <http://purl.org/dc/elements/1.1/>" 
    prefix << "prefix foaf:    <http://xmlns.com/foaf/0.1/#>" 

    select =  "SELECT #{select}"
    from =    "FROM <http://IulaClarinMetadata.edu>"
    where =   "WHERE {\n #{where} \n}"
    group_by = "GROUP BY #{group_by}" if group_by

    [prefix, select, from, where, group_by].join("\n")
  end

  def self.solution_is_resource?(solution)
    !solution[:olabel].to_s.empty?
  end

  def self.solution_is_label?(solution)
    solution[:p].to_s.match(/rdf-schema#label/) &&
      solution[:plabel].to_s.empty?
  end

  def self.solution_is_type?(solution)
    solution[:p].to_s.match(/22-rdf-syntax-ns#type/) &&
      !solution[:olabel].to_s.empty?
  end

  def self.solution_is_owl?(solution)
    solution[:p].to_s.match(/www.w3.org\/2002\/07\/owl/) 
  end


end
