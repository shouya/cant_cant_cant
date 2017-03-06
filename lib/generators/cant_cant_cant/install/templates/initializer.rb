Rails.application.config.after_initialize do
  perm_file = File.join(Rails.root, 'config/cant_cant_cant.yml')
  CantCantCant.initialize(perm_file) do |c|
    # - base_controller: Inject validation to the base controller
    # - individual:      Inject validation only to actions specified in config
    # c.injection_mode = :base_controller

    # This option is ignored unless c.injection_mode == :base_controller
    # c.base_controller = ActionController::Base

    # Specify what to do for unlisted access
    # c.default_policy = :allow

    # warn:   print a warning for unlisted actions and adopt default_policy
    # raise:  raise an exception for unlisted actions
    # ignore: ignore validation on unlisted actions and adopt default_policy
    # c.report_unlisted_actions = :ignore

    # Cache permission or load them from file for every request
    c.caching = Rails.env.production?
  end
end

class ActionController::Base
  # Write your own handler
  rescue_from CantCantCant::PermissionDenied do
    render plain: 'permission denied', status: 403
  end
  # Only useful when report_unlisted_actions is set :raise
  rescue_from CantCantCant::UnfilledAction do
    render plain: 'action unlisted in cantcantcant permission file'
  end

  # Write your own method to return the roles for current user
  def current_roles
    return [] unless defined? current_user
    return [] if current_user.empty?

    current_user.roles
  end
end
