# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  module Spree
    module Reviews
      Config = Spree::ReviewsConfiguration.new
    end
  end
end
