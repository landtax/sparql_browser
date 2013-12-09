module ResourcesHelper

  def resource_value(resource)
    if resource.id.nil?
      auto_link(resource.label)
    else
      link_to(resource.label, resource_path(resource.id)) 
    end
  end

end
