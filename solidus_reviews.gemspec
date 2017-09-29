Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_reviews'
  s.version     = '1.0.0'
  s.summary     = 'Basic review and ratings facility for Spree'
  s.authors 	  = ['Paul Callaghan']
  s.description = s.summary
  s.required_ruby_version = '>= 1.9.3'

  s.authors 	   = ['Paul Callaghan', 'Alex Blackie']
  s.email        = 'paulcc.two@gmail.com'
  s.homepage     = 'https://github.com/solidusio-contrib/solidus-reviews/'
  s.license      = 'BSD-3'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'solidus', ['>= 1.4', '< 3']
  s.add_dependency 'deface', '~> 1'
  s.add_dependency 'solidus_auth_devise', ['>= 1.0', '< 3']
  s.add_dependency 'solidus_support', '~> 0.1.1'

  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'pry'
end
