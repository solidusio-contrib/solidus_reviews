# frozen_string_literal: true

module Spree
  class ReviewsFeedsController < Spree::StoreController
    def show
      @approved_reviews = Spree::Review.approved.order(created_at: :desc)

      respond_to do |format|
        format.xml
      end
    end
  end
end
