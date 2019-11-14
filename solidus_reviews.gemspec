# frozen_string_literal: true

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_reviews'
  s.version     = '1.2.0'
  s.summary     = 'Basic review and ratings facility for Solidus'
  s.authors = ['Solidus Contrib']
  s.description = s.summary
  s.required_ruby_version = '>= 1.9.3'

  s.homepage     = 'https://github.com/solidusio-contrib/solidus_reviews/'
  s.license      = 'BSD-3'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'deface', '~> 1.0'
  s.add_dependency 'solidus', ['>= 1.4', '< 3']
  s.add_dependency 'solidus_support'

  s.add_development_dependency 'solidus_extension_dev_tools'
end
