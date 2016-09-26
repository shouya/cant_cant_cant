class CantCantCant::InstallGenerator < Rails::Generator::Base
  def create_config_file
    template 'config.yml', 'config/cant_cant_cant.yml'
  end

  def create_initializer_file
    template 'initializer.rb', 'config/initializers/cant_cant_cant.rb'
  end

  private

  def user_params
    routes = Rails.application.routes.routes.to_a.reject(&:internal)
    routes.map(&:defaults).reject(&:empty?).uniq
  end

  def user_permission_table
    map = {}
    user_params.each do |p|
      key = "#{p[:controller]}##{p[:action]}"
      map[key] = :deny
    end
    map
  end
end
