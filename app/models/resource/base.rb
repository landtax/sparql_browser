require 'ostruct'

class Resource::Base
  attr_accessor :id, :label, :type, :type_id, :attributes
  attr_accessor :attr_list

  def initialize(id, label, type, type_id, attributes)
    self.id = id
    self.label = label
    self.type = type
    self.type_id = type_id

    initialize_attributes(attributes)
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

  def self.find_all
    list = query query_find_all
  end

  def self.find_by_type(type)
    list = query query_find_by_type(type)
  end

  def self.find_by_id id
    build id, query(query_find_by_id(id))
  end

  def self.build_attribute(solution)
    label = ""

    if solution_is_resource?(solution)
      id = solution[:o].to_s.split("#")[1]
      label = solution[:olabel].to_s
    else
      label = solution[:o].to_s
    end

    type_id = solution[:p].to_s
    type = solution[:plabel].to_s

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
      else
        attributes << build_attribute(solution)
      end
    end

    Resource::Base.new(id, label, type, type_id, attributes)
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
    select =  "?s ?slabel"
    where = "?s rdf:type bio:#{type} ; rdfs:label ?slabel ."

    self.construct_query(select, where, nil)
  end

  def self.query(query)
    Rails.logger.debug(query)
    $sparql.query(query)
  end

  def self.construct_query select, where, group_by

    prefix = ["prefix ms: <http://gilmere.upf.edu/ms.ttl#>"]
    prefix << "prefix bio: <http://gilmere.upf.edu/bio.ttl#>"
    prefix << "prefix record: <http://gilmere.upf.edu/MetadataRecords.ttl#>"

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

end
