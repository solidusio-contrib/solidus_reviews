# frozen_string_literal: true
module SolidusReviews
  module Spree
    module ProductDecorator
      def self.prepended(base)
        base.class_eval do
          has_many :reviews
        end
      end

      def stars
        avg_rating.try(:round) || 0
      end

      def recalculate_rating
        reviews_count = reviews.reload.default_approval_filter.count

        self.reviews_count = reviews_count
        if reviews_count > 0
          self.avg_rating = '%.1f' % (reviews.default_approval_filter.sum(:rating).to_f / reviews_count)
        else
          self.avg_rating = 0
        end
        save
      end

      ::Spree::Product.prepend self
    end
  end
end
