config = File.join(Rails.root, 'config/cant_cant_cant.yml')
CantCantCant.initialize(config)

class ActionController::Base
  # Write your own handler
  rescue_from CantCantCant::PermissionDenied do
    render plain: 'permission denied', status: 403
  end

  # Write your own method to return the roles for current user
  def current_roles
    return [] unless defined? current_user
    return [] if current_user.empty?

    current_user.roles
  end
end
