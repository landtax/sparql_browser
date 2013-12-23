module ApplicationHelper

  def labelize(string)
    if string == "wsdl"
      "WSDL"
    else
      string.camelize.titleize
    end
  end

end


