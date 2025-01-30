# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'
require 'support/solidus_reviews/testing_support/factories'
require 'support/solidus_reviews/capybara'
require 'solidus_core'
require 'solidus_api'
require 'solidus_backend'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/url_helpers'

RSpec.configure do |config|
  config.include Spree::TestingSupport::UrlHelpers
end
