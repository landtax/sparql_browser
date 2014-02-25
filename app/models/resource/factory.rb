require 'ostruct'

class Resource::Factory

  def self.build(id, label, type, type_id, atts)
     case type.downcase
     when 'service'
       Service.new(id, label, type, type_id, atts)
     when 'task'
       Task.new(id, label, type, type_id, atts)
     end
  end

end
