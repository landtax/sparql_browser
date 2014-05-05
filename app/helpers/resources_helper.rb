module ResourcesHelper

  def resource_value(resource)
    link_or_value resource.label, resource.id
  end

end
