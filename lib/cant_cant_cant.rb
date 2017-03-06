require 'yaml'
require 'ostruct'
require 'set'
require_relative 'concern'

module CantCantCant
  PermissionDenied = Class.new(RuntimeError)
  InvalidConfiguration = Class.new(RuntimeError)
  UnfilledAction = Class.new(RuntimeError)

  class << self
    def initialize(config, &block)
      @config_file = config

      @config = OpenStruct.new(
        injection_mode: :base_controller,
        base_controller: ActionController::Base,
        default_policy: :allow,
        report_unfilled_actions: :ignore,
        caching: true
      )
      @config.instance_eval(&block) if block_given?

      @allow_cache = {}
      @deny_cache = {}

      validate_config

      case @config.injection_mode
      when :base_controller
        inject_base_controller
      when :individual
        inject_individual_actions
      end
    end

    def allow?(action, roles)
      return true if allowed_actions_for(roles).include? action
      return false if denied_actions_for(roles).include?(action)

      case @config.report_unfilled_actions
      # when :ignore, do nothing
      when :warn
        warn "Please fill in CantCantCant permission #{action}"
      when :raise
        raise UnfilledAction, [action, roles]
      end

      case @config.default_policy
      when :allow then true
      when :deny  then false
      end
    end

    def allowed_actions_for(roles)
      roles = [roles] unless roles.is_a? Array
      key = roles.sort.join(',')
      return @allow_cache[key] if @allow_cache[key] && @config.caching

      perms = permission_table
              .values_at(*roles.map(&:to_s))
              .select(&:present?)
      allowed_perms = perms
                      .map { |x| x.select { |_, v| v == 'allow' }.keys }
                      .flatten
                      .uniq
      @allow_cache[key] = allowed_perms.to_set
    end

    def all_actions
      @all_actions = nil unless @config.caching
      @all_actions ||= permission_table
                       .values
                       .map(&:keys)
                       .flatten
                       .uniq
                       .to_set
    end

    def denied_actions_for(roles)
      roles = [roles] unless roles.is_a? Array
      key = roles.sort.join(',')
      return @deny_cache[key] if @deny_cache[key] && @config.caching
      @deny_cache[key] = all_actions - allowed_actions_for(roles)
    end

    private

    def inject_base_controller
      base_controller_class = @config.base_controller
      base_controller_class.before_action CantCantCantAuth
    end

    def inject_individual_actions
      controller_actions = all_actions
                           .map { |x| extract_controller(x) }
                           .group_by(&:first)
      controller_actions.each do |controller, actions|
        actions = actions.map(&:second)
        controller.before_action CantCantCantAuth, only: actions
      end
    end

    def permission_table
      @permission_table = nil unless @config.caching
      @permission_table ||= YAML.load_file(@config_file).freeze
    end

    def extract_controller(param)
      controller_param, action = param.split('#')
      raise if controller_param.blank? || action.blank?

      const_name = "#{controller_param.camelize}Controller"
      controller_class = ActiveSupport::Dependencies.constantize(const_name)

      [controller_class, action]
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
