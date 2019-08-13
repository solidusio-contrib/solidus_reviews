# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"

require File.expand_path('dummy/config/environment.rb', __dir__)

# Requires factories and other useful helpers defined in spree_core.
require "solidus_support/extension/feature_helper"
require 'spree/testing_support/controller_requests'
require 'selenium/webdriver'

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

require 'solidus_reviews/factories'

RSpec.configure do |config|
  config.include Spree::TestingSupport::ControllerRequests, type: :controller

  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  Capybara.register_driver :selenium_chrome_headless do |app|
    browser_options = ::Selenium::WebDriver::Chrome::Options.new
    browser_options.args << '--headless'
    browser_options.args << '--disable-gpu'
    browser_options.args << '--window-size=1440,1080'
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end

  Capybara.javascript_driver = (ENV['CAPYBARA_DRIVER'] || :selenium_chrome_headless).to_sym

  if Gem.loaded_specs['solidus'].version < Gem::Version.new('2.4')
    config.include VersionCake::TestHelpers, type: :controller
    config.before(:each, type: :controller) do
      set_request_version('', 1)
    end
  end
end
