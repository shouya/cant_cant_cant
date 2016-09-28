require_relative 'boot'
require 'rails'
require "action_controller/railtie"

Bundler.require(*Rails.groups)
require "cant_cant_cant"

module Dummy
  class Application < Rails::Application
  end
end

