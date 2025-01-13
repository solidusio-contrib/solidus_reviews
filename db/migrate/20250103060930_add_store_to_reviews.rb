# frozen_string_literal: true

class AddStoreToReviews < ActiveRecord::Migration[7.2]
  def self.up
    add_column :spree_reviews, :store_id, :integer, null: false
  end

  def self.down
    remove_column :spree_reviews, :store_id
  end
end
