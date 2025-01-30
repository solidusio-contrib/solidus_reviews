# frozen_string_literal: true

module SolidusReviews
  module ProductsControllerDecorator
    def self.prepended(base)
      base.class_eval do
        helper ::Spree::ReviewsHelper
      end
    end

    ::ProductsController.prepend self
  end
end
