# frozen_string_literal: true

Spree::Api::ApiHelpers.module_eval do
  @@review_attributes = [
    :id, :product_id, :name, :location, :rating, :title, :review, :approved,
    :created_at, :updated_at, :user_id, :ip_address, :locale, :show_identifier
  ]

  def review_attributes
    @@review_attributes
  end
end
