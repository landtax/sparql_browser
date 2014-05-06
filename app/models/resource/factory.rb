require 'ostruct'

class Resource::Factory

  def self.super_class_of subclass
    superclasses = $sparql_cache.fetch('superclass') do
      sparql_super_classes= find_translations.inject({}) { |ret, s| ret[s[:a].to_s.split("#")[1]] = s[:b].to_s.split("#")[1]; ret }
      ["Service", "Task", "Corpus", "Document", "LexicalConceptualResource", "Project"].each { |t| sparql_super_classes[t] = t }
      sparql_super_classes
    end
    superclasses[subclass]
  end

  def self.find_translations
    query = <<EOF
    #{Resource::Base.namespaces}
select *
    #{Resource::Base.from}
 where { ?a browser:topNode ?b .}
EOF

    Resource::Base.query(query)
  end

  def self.build(id, label, type, type_id, atts)
    super_class = self.super_class_of(type) || ""

     case super_class.downcase
     when 'service'
       Service.new(id, label, type, type_id, atts)
     when 'task'
       Task.new(id, label, type, type_id, atts)
     when 'lexicalconceptualresource'
       Lexica.new(id, label, type, type_id, atts)
     when 'corpus'
       Corpus.new(id, label, type, type_id, atts)
     when 'document'
       Document.new(id, label, type, type_id, atts)
     when 'project'
       Project.new(id, label, type, type_id, atts)
     else
       Resource::Base.new(id, label, type, type_id, atts)
     end
  end

end
