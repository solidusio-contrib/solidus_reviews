# frozen_string_literal: true

module Spree
  module Reviews
  end
end

Rails.application.reloader.to_prepare do
  Spree::Reviews.const_set(:Config, Spree::ReviewsConfiguration.new)
end
