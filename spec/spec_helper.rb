require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

# Requires factories and other useful helpers defined in spree_core.
require "solidus_support/extension/feature_helper"
require 'spree/testing_support/controller_requests'

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f }

require 'solidus_reviews/factories'

RSpec.configure do |config|
  config.include Spree::TestingSupport::ControllerRequests, type: :controller

  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  Capybara.javascript_driver = :poltergeist
end
