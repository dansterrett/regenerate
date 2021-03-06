$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "regenerate/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "regenerate"
  s.version     = Regenerate::VERSION
  s.authors     = ["Dan Sterrett, Nicholas Watson"]
  s.email       = ["dan@entropi.co"]
  s.homepage    = "http://github.com/entropillc/regenerate"
  s.summary     = "TODO: Summary of Regenerate."
  s.description = "TODO: Description of Regenerate."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.1"
  
  s.add_development_dependency 'rails', '>= 3.1'
  s.add_development_dependency 'rspec-rails', '>= 2.6.1'
  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'cucumber', '~> 1.0.6'
  s.add_development_dependency "bundler"
end
