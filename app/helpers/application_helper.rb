module ApplicationHelper

  def labelize(string)
    if ["WSDL", "LMF"].include? string.upcase
      string.upcase
    else
      string.camelize.titleize
    end
  end

end


