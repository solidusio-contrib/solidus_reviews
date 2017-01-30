source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'v1.4')
gem "solidus", github: "solidusio/solidus", branch: branch
gem "solidus_auth_devise", github: "solidusio/solidus_auth_devise"

case ENV['DB']
when 'mysql'
  gem 'mysql2'
when 'postgresql'
  gem 'pg'
end

gemspec
