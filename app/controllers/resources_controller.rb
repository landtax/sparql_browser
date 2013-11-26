class ResourcesController < ApplicationController
  def index

sparql = SPARQL::Client.new("http://iula02v.upf.edu:8890/sparql")
query_2 =<<EOF

prefix ms: <http://gilmere.upf.edu/ms.ttl#>
prefix bio: <http://gilmere.upf.edu/bio.ttl#>

SELECT ?p COUNT(?p) as ?pCount
FROM <http://IulaClarinMetadata.edu>
WHERE
{
 ?s bio:task ?p .
}
GROUP BY ?p
EOF

@result = sparql.query(query_2)

  end

  def show
  end
end
