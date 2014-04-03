class Document < Resource::Base

  def priority_attr
    %w{ Title Creator "Bibliographic Citation" sameAs subject References identifier }
  end

  def banned_attr
    %w{name type}
  end

  def self.facets_available
    ['subject', 'related_services', 'related_resources', 'topic']
  end

  def self.find_all_query
    query = <<EOF
    #{namespaces}
SELECT ?s_id ?s ?dlabel
    #{from}
WHERE
{
 ?s_id a ?document ; rdfs:label ?s .
 ?document rdfs:subClassOf ms:Document ; rdfs:label ?dlabel.
}
GROUP BY ?document ORDER BY ?dlabel

EOF

    self.query(query)
  end

  def self.find_all_faceted_by_subject
    query = <<EOF
    #{namespaces}
SELECT *
    #{from}
{
    {
        SELECT ?subject_id ?subject ?doc_id ?doc ?citation {
            ?doc_id dc:subject ?subject_id ; rdfs:label ?doc  ; dcterms:bibliographicCitation ?citation.
            ?subject_id rdfs:label ?subject .
        }
    }
}
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_related_services
    query = <<EOF
    #{namespaces}
SELECT *
    #{from}
 {
    {
        SELECT ?resource AS ?page_id ?resourceLabel AS ?page ?doc AS ?document_id ?docLabel AS ?document ?docCitation AS ?citation {
            ?resource ms:documentation ?doc; rdfs:label ?resourceLabel ; a bio:Service .
            ?doc rdfs:label ?docLabel ; dcterms:bibliographicCitation ?docCitation .
        }
    } UNION {
        SELECT ?ref AS ?page_id ?refLabel AS ?page ?doc AS ?document_id ?docLabel AS ?document ?docCitation AS ?citation {
            ?doc dcterms:references ?ref ; rdfs:label ?docLabel ; dcterms:bibliographicCitation ?docCitation .
            ?ref rdfs:label ?refLabel ; a bio:Service .
        }
    }
} GROUP BY ?page ORDER BY ?label
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_related_resources
    query = <<EOF
    #{namespaces}
SELECT * 
    #{from}
{  ?page_id a owl:NamedIndividual
    {
        SELECT ?resource AS ?page_id ?resourceLabel AS ?page ?doc AS ?document_id ?docLabel AS ?document  ?docCitation AS ?citation {
            ?resource ms:documentation ?doc; rdfs:label ?resourceLabel .
            ?doc rdfs:label ?docLabel ; dcterms:bibliographicCitation ?docCitation  .
        }
    } UNION {
        SELECT ?resource AS ?page_id ?resourceLabel AS ?page ?doc AS ?document_id ?docLabel AS ?document {
            ?doc dcterms:references ?resource; rdfs:label ?docLabel  ; dcterms:bibliographicCitation ?docCitation.
            ?resource rdfs:label ?resourceLabel .
        }
    }
FILTER
      (
        !bif:exists
         (
           ( SELECT (1)
             WHERE
               {
                 ?page_id a bio:Service
               }
           )
         )
      )
} GROUP BY ?page_id ORDER BY ?page
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_topic
    query = <<EOF
    #{namespaces}
SELECT ?topic_id ?topic ?doc_id ?doc ?citation
    #{from}
WHERE {  ?doc_id rdfs:label ?doc ; dc:subject ?topic_id ; dcterms:bibliographicCitation ?citation.  ?topic_id rdfs:label  ?topic .}
GROUP BY ?topic_id ORDER BY ?topic
EOF

    self.query(query)
  end

  def find_all_documented_resources
    query = <<EOF
    #{Resource::Base.namespaces}
SELECT ?resource_id ?resource
    #{Resource::Base.from}
WHERE {
?resource_id ms:documentation test:#{id} ; rdfs:label ?resource.
}
EOF
   SolutionsBrowser.new( Resource::Base.query(query) )
  end

end
