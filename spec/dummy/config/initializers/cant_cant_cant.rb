config = File.join(Rails.root, 'config/cant_cant_cant.yml')
CantCantCant.initialize(config)

class ActionController::Base
  # Write your own handler
  rescue_from CantCantCant::PermissionDenied do
    render plain: 'permission denied', status: 401
  end

  # Write your own method to return the roles for current user
  def current_roles
    (params[:roles] || 'user').split(',')
  end
end
