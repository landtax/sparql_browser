module ApplicationHelper

  def labelize(string)
    stands = ["WSDL", "LMF", "RDF", "OWL"]
    res = if stands.include? string.upcase
      string.upcase
    else
      string.camelize.titleize
    end

    res.gsub(/Lmf/, "LMF").gsub(/Wsdl/, "WSDL").gsub(/Rdf/, "RDF").gsub(/Owl/, "OWL")
  end

end


