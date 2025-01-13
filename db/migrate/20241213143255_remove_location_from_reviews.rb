# frozen_string_literal: true

class RemoveLocationFromReviews < ActiveRecord::Migration[7.2]
  def change
    remove_column :spree_reviews, :location
  end
end
