require 'yaml'

module CantCantCant
  class PermissionDenied < RuntimeException; end
  class InvalidControllerOrAction < RuntimeException; end
  class InvalidConfiguration < RuntimeException; end

  CONFIG_FILE = File.join(Rails.root, 'config/cant_cant_cant.yml').freeze

  def inject_actions
    validate_config

    permission_table.values.map(&:keys).flatten.uniq.each do |param|
      inject_action(param)
    end
  end

  def allow?(param, roles)
    return false if roles.empty?
    roles.each do |role|
      role_spec = permission_table[role]
      next if role_spec[param].empty?
      next if role_spec[param] == 'deny'
      return true if role_spec[param] == 'allow'
    end
    false
  end

  private

  def permission_table
    @permission_table ||= YAML.load_file(CONFIG_FILE).freeze
  end

  def extract_controller(param)
    controller, action = param.split('#')
    raise if controller.empty? || action.empty?

    controller = (controller.classify + 'Controller').constantize
    raise unless controller.instance_methods(false).map(&:to_s).include? action

    [controller, action]
  rescue RuntimeError, NameError
    raise InvalidControllerOrAction, param
  end

  def inject_action(param)
    controller, action = extract_controller(param)
    controller.class_eval do
      set_callback(action, :before) do
        raise PermissionDenied, param unless allowed?(param, roles)
      end
    end
  end

  def validate_config
    permission_table.each do |_, perms|
      perms.each do |params, access|
        raise InvalidConfiguration, params unless access.in? %w(allow deny)
      end
    end
  end
end
