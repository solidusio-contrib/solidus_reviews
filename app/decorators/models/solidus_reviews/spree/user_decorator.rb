# frozen_string_literal: true

module SolidusReviews
  module Spree
    module UserDecorator
      def self.prepended(base)
        base.class_eval do
          has_many :reviews, class_name: 'Spree::Review'
        end
      end

      ::Spree.user_class.prepend self
    end
  end
end
