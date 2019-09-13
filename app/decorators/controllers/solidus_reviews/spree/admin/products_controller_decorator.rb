# frozen_string_literal: true

module SolidusReviews
  module Spree
    module ProductsControllerDecorator
      def self.prepended(base)
        base.class_eval do
          helper ::Spree::ReviewsHelper
        end

        [:avg_rating, :reviews_count].each do |attribute|
          ::Spree::PermittedAttributes.product_attributes << attribute
        end
      end

      ::Spree::ProductsController.prepend self
    end
  end
end
