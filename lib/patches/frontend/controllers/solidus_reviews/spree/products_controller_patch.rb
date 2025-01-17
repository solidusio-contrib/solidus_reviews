# frozen_string_literal: true

module SolidusReviews
  module Spree
    module ProductsControllerPatch
      def self.prepended(base)
        base.class_eval do
          helper ::Spree::ReviewsHelper
        end
      end

      ::Spree::ProductsController.prepend self
    end
  end
end
