$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cant_cant_cant/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cant_cant_cant"
  s.version     = CantCantCant::VERSION
  s.authors     = ["Shou Ya"]
  s.email       = ["github@lain.li"]
  s.homepage    = "https://github.com/shouya/cantcantcant"
  s.summary     = "CanCan[Can] just can't satisfy me"
  s.description = s.summary
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.0.0"
end
