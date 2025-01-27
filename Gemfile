# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

branch = ENV.fetch('SOLIDUS_BRANCH', 'main')
gem 'solidus', github: 'solidusio/solidus', branch: branch

# Needed for Rails 7.0
gem 'concurrent-ruby', '< 1.3.5'

gem 'faraday-retry', '~> 2.0'

gem 'rubocop-rails-omakase'
# Needed to help Bundler figure out how to resolve dependencies,
# otherwise it takes forever to resolve them.
# See https://github.com/bundler/bundler/issues/6677
gem 'rails', '>0.a'

case ENV.fetch('DB', nil)
when 'mysql'
  gem 'mysql2'
when 'postgresql'
  gem 'pg'
else
  gem 'sqlite3', '~> 1.4'
end

# While we still support Ruby < 3 we need to workaround a limitation in
# the 'async' gem that relies on the latest ruby, since RubyGems doesn't
# resolve gems based on the required ruby version.
gem 'async', '< 3' if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3')

gemspec

# Use a local Gemfile to include development dependencies that might not be
# relevant for the project or for other contributors, e.g. pry-byebug.
#
# We use `send` instead of calling `eval_gemfile` to work around an issue with
# how Dependabot parses projects: https://github.com/dependabot/dependabot-core/issues/1658.
send(:eval_gemfile, 'Gemfile-local') if File.exist? 'Gemfile-local'
