require 'yaml'

module CantCantCant
  class PermissionDenied < RuntimeException; end
  class ActionNotFound < RuntimeException; end

  CONFIG_FILE = File.join(Rails.root, 'config/cantcantcant.yml').freeze

  def allow?(action_ref, roles)
    roles.each do
      return true if permissions_table[action_ref].include?(role)
    end
    false
  end

  def roles_permissions(roles)
    table = []
    roles.map do |role|
      table |= inverted_permissions[role]
    end
    table
  end

  private

  def config
    @config ||= YAML.load_file(CONFIG_FILE).freeze
  end

  def permissions
    @permissions ||= config['permissions'].freeze
  end

  def inverted_permissions
    return @inverted_permissions if @inverted_permissions

    @inverted_permissions = Hash.new { [] }
    permissions.each do |action_ref, roles|
      roles.each do |role|
        @inverted_permissions[role] << action_ref
      end
    end.freeze
    @inverted_permissions
  end

  def inject_action(action_ref)
    controller = parse_controller(action)
    action = parse_action(controller, action_ref)

    controller.class_eval do
      set_callback(action, :before) do
        raise PermissionDenied, action_ref unless allow?(action_ref, roles)
      end
    end
  end

  def roles
    # todo
  end

  def parse_controller(action_ref)
    (action_ref.split('#').first.classify + 'Controller').constantize
  end

  def parse_action(controller, action_ref)
    action = action_ref.split('#').last.intern
    actions = controller.instance_methods(false)
    raise ActionNotFound, action_ref unless action.in?(actions)
    action
  end
end
