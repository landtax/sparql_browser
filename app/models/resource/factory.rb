require 'ostruct'

class Resource::Factory


  def self.build(type)
     case type.downcase
     when 'service'
       Service.new
     when 'task'
       Task.new
     end
  end


end
