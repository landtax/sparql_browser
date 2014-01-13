class Corpus < Resource::Base

  def self.facets_available
    ['annotation_type', 'linguality', 'language', 'funding_project']
  end

  def self.find_all_query
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
prefix test: <http://gilmere.upf.edu/MetadataRecords.ttl#>
SELECT ?corpus_id ?corpus
WHERE
{?corpus_id a ?class ; rdfs:label ?corpus .
 ?class rdfs:subClassOf ms:Corpus
 } GROUP BY ?corpus_id ORDER BY ?corpus
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_annotation_type
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
prefix test: <http://gilmere.upf.edu/MetadataRecords.ttl#>
SELECT ?annotation_id ?annotation ?corpus_id ?corpus  ?description
WHERE{
 ?corpus_id a ?class ; rdfs:label ?corpus ; ms:annotationType ?annotation_id  ; dc:description ?description .
 ?class rdfs:subClassOf ms:Corpus .
?annotation_id rdfs:label ?annotation 
 }
GROUP BY ?annotation_id ORDER BY ?annotation
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_linguality
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
prefix test: <http://gilmere.upf.edu/MetadataRecords.ttl#>
SELECT ?linguality_id ?linguality ?corpus_id ?corpus ?description
WHERE{
 ?corpus_id a ?class ; rdfs:label ?corpus ; ms:linguality ?linguality_id ; dc:description ?description .
 ?class rdfs:subClassOf ms:Corpus .
?linguality_id rdfs:label ?linguality
 }
GROUP BY ?linguality_id ORDER BY ?linguality
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_language
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
prefix test: <http://gilmere.upf.edu/MetadataRecords.ttl#>
SELECT ?lang ?corpus_id ?corpus ?description 
WHERE{
 ?corpus_id a ?class ; rdfs:label ?corpus ; ms:languageId ?lang ; dc:description ?description .
 ?class rdfs:subClassOf ms:Corpus .
 }
GROUP BY ?lang ORDER BY ?lang
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_funding_project
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
prefix test: <http://gilmere.upf.edu/MetadataRecords.ttl#>
SELECT ?funding_project_id ?funding_project ?corpus_id ?corpus ?description
WHERE{
 ?corpus_id a ?class ; rdfs:label ?corpus ; ms:fundingProject ?funding_project_id ; dc:description ?description  .
 ?class rdfs:subClassOf ms:Corpus .
?funding_project_id rdfs:label ?funding_project
 }
GROUP BY ?funding_project_id ORDER BY ?funding_project
EOF

    self.query(query)
  end
end
