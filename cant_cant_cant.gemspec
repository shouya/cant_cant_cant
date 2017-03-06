$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cant_cant_cant"
  s.version     = "0.1.10"
  s.authors     = ["Shou Ya"]
  s.email       = ["github@lain.li"]
  s.homepage    = "https://github.com/shouya/cant_cant_cant"
  s.summary     = "CanCan[Can] just can't satisfy me"
  s.description = s.summary
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.require_path = 'lib'

  s.add_dependency "rails", ">= 4.2.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
