module ApplicationHelper

  def labelize(string)
    if string == "wsdl"
      "WSDL"
    else
      string.camelize.titleize
    end
  end


  def print_solution_attribute

  end

end


