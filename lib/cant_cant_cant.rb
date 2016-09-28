require 'yaml'

module CantCantCant
  PermissionDenied = Class.new(RuntimeError)
  InvalidControllerOrAction = Class.new(RuntimeError)
  InvalidConfiguration = Class.new(RuntimeError)

  class << self
    def initialize(config)
      @config_file = config
      @cache = {}

      inject_actions
    end

    def inject_actions
      validate_config

      permission_table.values.map(&:keys).flatten.uniq.each do |param|
        inject_action(param)
      end
    end

    def allow?(param, roles)
      permissions_for(roles).include? param
    end

    def permissions_for(roles)
      @cache[roles.sort.join(',')] ||=
        permission_table
        .values_at(*roles)
        .select(&:present?)
        .map { |x| x.keep_if { |_, v| v == 'allow' }.keys }
        .flatten
        .uniq
    end

    private

    def permission_table
      @permission_table ||= YAML.load_file(@config_file).freeze
    end

    def extract_controller(param)
      controller, action = param.split('#')
      raise if controller.blank? || action.blank?

      controller = (controller + '_controller').classify.constantize
      raise unless action.in? controller.instance_methods(false).map(&:to_s)

      [controller, action]
    rescue RuntimeError, NameError
      raise InvalidControllerOrAction, param
    end

    def inject_action(param)
      controller, action = extract_controller(param)
      controller.class_eval do
        before_action(only: [action]) do
          next true if CantCantCant.allow?(param, current_roles)
          raise PermissionDenied, param
        end
      end
    end

    def validate_config
      permission_table.each do |_, perms|
        perms.each do |param, access|
          next unless access.blank?
          next unless access.in? %w(allow deny)
          raise InvalidConfiguration, param
        end
      end
    end
  end
end
