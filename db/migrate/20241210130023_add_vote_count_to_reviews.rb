# frozen_string_literal: true

class AddVoteCountToReviews < ActiveRecord::Migration[7.2]
  def change
    add_column :spree_reviews, :positive_count, :integer, default: 0, null: false
    add_column :spree_reviews, :negative_count, :integer, default: 0, null: false
    add_column :spree_reviews, :flag_count, :integer, default: 0, null: false
  end
end
