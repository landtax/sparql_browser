class Lexica < Resource::Base

  def priority_attr
    %w{ resourceName description type languageName documentation resourceCreator fundingProject contactPerson  identfier url linguality annotationType segmentationLevel }
  end

  def banned_attr
    %w{ name languageCode resourceShortName language metashareId }
  end

  def self.facets_available
    ['encoding_level', 'linguistic_information', 'linguality', 'language', 'standards', 'funding_project', 'type']
  end

  def self.find_all_query
    query = <<EOF
    #{namespaces}
SELECT ?lex_id ?lex ?description
    #{from}
WHERE{
 ?lex_id a ?class ; rdfs:label ?lex ; dc:description ?description .
?class browser:topNode ms:LexicalConceptualResource .
 }
GROUP BY ?lex_id ?lex ?description
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_encoding_level
    query = <<EOF
    #{namespaces}
SELECT ?enc_id ?enc ?lex_id ?lex ?description
    #{from}
WHERE{
 ?lex_id a ?class ; rdfs:label ?lex ; ms:encodingLevel ?enc_id ; dc:description ?description .
?class browser:topNode ms:LexicalConceptualResource .
?enc_id rdfs:label ?enc
 }
GROUP BY ?enc_id ORDER BY ?enc
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_linguistic_information
    query = <<EOF
    #{namespaces}
SELECT ?ling_id ?ling ?lex_id ?lex ?description
    #{from}
WHERE{
 ?lex_id a ?class ; rdfs:label ?lex ; ms:linguisticInformation ?ling_id ; dc:description ?description .
?ling_id rdfs:label ?ling .
?class browser:topNode ms:LexicalConceptualResource .
}
GROUP BY ?ling_id ORDER BY ?ling
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_linguality
    query = <<EOF
    #{namespaces}

SELECT ?linguality_id ?linguality ?lex_id ?lex ?description
    #{from}
WHERE{
 ?lex_id a ?class ; rdfs:label ?lex ; ms:linguality ?linguality_id ; dc:description ?description .
?linguality_id rdfs:label ?linguality .
?class browser:topNode ms:LexicalConceptualResource .
}
GROUP BY ?linguality_id ORDER BY ?linguality
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_language
    query = <<EOF
    #{namespaces}
SELECT ?lang ?lex_id ?lex ?description
    #{from}
WHERE{
 ?lex_id a ?class  ; rdfs:label ?lex ; ms:languageId ?lang ; dc:description ?description .
?class browser:topNode ms:LexicalConceptualResource .
} GROUP BY ?lang ORDER BY ?lang
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_standards
    query = <<EOF
    #{namespaces}

SELECT ?ling_id ?ling ?lex_id ?lex ?description
    #{from}
WHERE{
 ?lex_id a ?class ; rdfs:label ?lex ; ms:conformanceToStandardsBestPractices ?ling_id ; dc:description ?description .
?ling_id rdfs:label ?ling .
?class browser:topNode ms:LexicalConceptualResource .
 }
GROUP BY ?ling_id ORDER BY ?ling
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_funding_project
    query = <<EOF
    #{namespaces}
SELECT ?project_id ?project ?lex_id ?lex ?description
    #{from}
WHERE{
 ?lex_id a ?class ; rdfs:label ?lex ; ms:fundingProject ?project_id ; dc:description ?description .
?project_id rdfs:label ?project.
?class browser:topNode ms:LexicalConceptualResource . 
 }
EOF

    self.query(query)
  end

  def self.find_all_faceted_by_type
    query = <<EOF
    #{namespaces}
    SELECT ?type_id ?type ?lex_id ?lex
    #{from}
WHERE { ?lex_id a ?type_id ; rdfs:label ?lex .
?type_id rdfs:subClassOf ms:LexicalConceptualResource ;
rdfs:label ?type . }
GROUP BY ?type_id ORDER BY ?type_id
EOF

    self.query(query)
  end
end
