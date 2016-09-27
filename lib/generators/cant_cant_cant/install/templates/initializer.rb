class ActionController::Base
  # Write your own method to return the roles for current user
  def current_roles
    return [] unless defined? current_user
    return [] if current_user.empty?

    current_user.roles
  end
end
