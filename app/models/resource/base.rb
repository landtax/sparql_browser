require 'ostruct'

class Resource::Base
  attr_accessor :attributes, :attr_list

  def initialize(params)
    self.attributes = OpenStruct.new(params)
    self.attr_list = params.keys
  end

  def self.find_all
    list = query query_find_all
  end

  def self.find_by_id id
    new(solutions_to_hash(query(query_find_by_id(id))))
  end

  def self.solutions_to_hash(solutions)
    attributes = {}
    solutions.each_solution do |solution|
      key = solution[:plabel].to_s
      value = solution[:o].to_s

      if attributes.keys.include?(key)
        unless attributes[key].kind_of?(Array)
          attributes[key] = [attributes[key]]
        end
        attributes[key] << value
      else
        attributes[key] = value
      end
    end
    attributes
  end

  protected

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


end
