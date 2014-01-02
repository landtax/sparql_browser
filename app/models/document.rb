class Document < Resource::Base

  def self.find_all_by_facet(facet)
    normal_facet = facet.downcase
    return [] unless ['subject', 'related_services', 'related_resources', 'topic'].include? normal_facet.downcase
    solutions = self.send(:"find_all_faceted_by_#{normal_facet}")
    SolutionsBrowser.new(solutions)
  end

  def self.find_all_faceted_by_subject
    query = <<EOF
prefix dc:  <http://purl.org/dc/elements/1.1/>
prefix dcterms:  <http://purl.org/dc/terms/>
SELECT * { 
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
prefix dc:  <http://purl.org/dc/elements/1.1/>
prefix dcterms:  <http://purl.org/dc/terms/>
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
SELECT * { 
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
prefix dc:  <http://purl.org/dc/elements/1.1/>
prefix dcterms:  <http://purl.org/dc/terms/>
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
SELECT * {  ?page_id a owl:NamedIndividual
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
prefix dc:  <http://purl.org/dc/elements/1.1/>
prefix dcterms:  <http://purl.org/dc/terms/>
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
SELECT ?topic_id ?topic ?doc_id ?doc ?citation
WHERE {  ?doc_id rdfs:label ?doc ; dc:subject ?topic_id ; dcterms:bibliographicCitation ?citation.  ?topic_id rdfs:label  ?topic .}
GROUP BY ?topic_id ORDER BY ?topic
EOF

    self.query(query)
  end

end
