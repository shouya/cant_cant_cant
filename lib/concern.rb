class CantCantCantAuth
  def self.before(controller)
    roles = controller.current_roles
    params = controller.params
    action = "#{params[:controller]}\##{params[:action]}"
    return true if CantCantCant.allow?(action, roles)
    raise CantCantCant::PermissionDenied, [action, roles]
  end
end
