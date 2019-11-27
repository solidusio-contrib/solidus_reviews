# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require 'solidus_reviews/version'

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'solidus_reviews'
  s.version = SolidusReviews::VERSION
  s.summary = 'Review and rating functionality for your Solidus store.'
  s.authors = ['Solidus Contrib']
  s.description = s.summary
  s.required_ruby_version = '>= 1.9.3'

  s.homepage = 'https://github.com/solidusio-contrib/solidus_reviews'
  s.license = 'BSD-3'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'deface', '~> 1.0'
  s.add_dependency 'solidus', ['>= 1.4', '< 3']
  s.add_dependency 'solidus_support'

  s.add_development_dependency 'solidus_extension_dev_tools'
end
