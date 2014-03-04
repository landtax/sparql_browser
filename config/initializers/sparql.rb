$sparql = SPARQL::Client.new("http://iula02v.upf.edu/sparql")
$sparql_cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 5.minutes)
