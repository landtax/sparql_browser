class Lexica < Resource::Base

  def self.find_all_by_facet(facet)
    normal_facet = facet.downcase
    return [] unless ['type', 'encoding_level', 'linguistic_information', 'linguality', 'language', 'standards', 'funding_project'].include? normal_facet.downcase
    solutions = self.send(:"find_all_faceted_by_#{normal_facet}")
    SolutionsBrowser.new(solutions)
  end

  def self.find_all_faceted_by_type
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
prefix test: <http://gilmere.upf.edu/MetadataRecords.ttl#>
SELECT ?lex_id ?lex
WHERE
{ ?lex_id a ms:LexicalConceptualResource ; rdfs:label ?lex .
 } GROUP BY ?lex_id ?lex ORDER BY ?lex

EOF

    self.query(query)
  end

  def self.find_all_faceted_by_encoding_level
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
prefix test: <http://gilmere.upf.edu/MetadataRecords.ttl#>
SELECT ?enc_id ?enc ?lex_id ?lex ?description
WHERE{
 ?lex_id a ms:LexicalConceptualResource; rdfs:label ?lex ; ms:encodingLevel ?enc_id ; dc:description ?description .
?enc_id rdfs:label ?enc 
 }
GROUP BY ?enc_id ORDER BY ?enc
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_linguistic_information
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
prefix test: <http://gilmere.upf.edu/MetadataRecords.ttl#>
SELECT ?ling_id ?ling ?lex_id ?lex ?description
WHERE{
 ?lex_id a ms:LexicalConceptualResource; rdfs:label ?lex ; ms:linguisticInformation ?ling_id ; dc:description ?description .
?ling_id rdfs:label ?ling 
}
GROUP BY ?ling_id ORDER BY ?ling
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_linguality
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
prefix test: <http://gilmere.upf.edu/MetadataRecords.ttl#>
SELECT ?linguality_id ?linguality ?lex_id ?lex ?description
WHERE{
 ?lex_id a ms:LexicalConceptualResource ; rdfs:label ?lex ; ms:linguality ?linguality_id ; dc:description ?description .
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
SELECT ?lang ?lex_id ?lex ?description
WHERE{
 ?lex_id a ms:LexicalConceptualResource  ; rdfs:label ?lex ; ms:languageId ?lang ; dc:description ?description .
} GROUP BY ?lang ORDER BY ?lang
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_standards
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
prefix test: <http://gilmere.upf.edu/MetadataRecords.ttl#>
SELECT ?ling_id ?ling ?lex_id ?lex ?description
WHERE{
 ?lex_id a ms:LexicalConceptualResource; rdfs:label ?lex ; ms:conformanceToStandardsBestPractices ?ling_id ; dc:description ?description .
?ling_id rdfs:label ?ling 
 }
GROUP BY ?ling_id ORDER BY ?ling
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_funding_project
    query = <<EOF
prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>
prefix dc:  <http://purl.org/dc/elements/1.1/> 
prefix test: <http://gilmere.upf.edu/MetadataRecords.ttl#>
SELECT ?funding_project_id ?funding_project ?lex_id ?lex ?description
WHERE{
 ?lex_id a ms:LexicalConceptualResource ; rdfs:label ?lex ; ms:fundingProject ?funding_project_id ; dc:description ?description .
?funding_project_id rdfs:label ?funding_project
 }
GROUP BY ?funding_project_id ORDER BY ?funding_project
EOF

    self.query(query)
  end
end
