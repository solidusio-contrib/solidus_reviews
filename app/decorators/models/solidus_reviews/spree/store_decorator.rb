# frozen_string_literal: true

module SolidusReviews
  module Spree
    module StoreDecorator
      def self.prepended(base)
        base.class_eval do
          has_many :reviews, class_name: 'Spree::Review'
        end
      end

      ::Spree::Store.prepend self
    end
  end
end
