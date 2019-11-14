# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    Spree::Reviews::Config.reset
  end
end
