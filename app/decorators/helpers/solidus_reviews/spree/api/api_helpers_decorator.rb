# frozen_string_literal: true

module SolidusReviews
  module Spree
    module Api
      module ApiHelpersDecorator
        def self.prepended(base)
          base.module_eval do
            @@review_attributes = [
              :id, :product_id, :name, :rating, :title, :review, :approved,
              :created_at, :updated_at, :user_id, :ip_address, :locale, :show_identifier,
              :verified_purchaser
            ]

            def review_attributes
              @@review_attributes
            end
          end
        end

        ::Spree::Api::ApiHelpers.prepend self
      end
    end
  end
end
