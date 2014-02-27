require 'ostruct'

class Resource::Factory

  def self.build(id, label, type, type_id, atts)
     case type.downcase
     when 'service'
       Service.new(id, label, type, type_id, atts)
     when 'task'
       Task.new(id, label, type, type_id, atts)
     when 'lexica'
       Lexica.new(id, label, type, type_id, atts)
     when 'corpus'
       Corpus.new(id, label, type, type_id, atts)
     when 'document', 'article'
       Document.new(id, label, type, type_id, atts)
     else
        Resource::Base.new(id, label, type, type_id, atts)
     end
  end

end
