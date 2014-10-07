$sparql = SPARQL::Client.new("http://lodserver.iula.upf.edu/sparql")
$sparql_cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 5.minutes)
