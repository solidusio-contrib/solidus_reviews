# frozen_string_literal: true

class CreateReviewVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :spree_review_votes do |t|
      t.integer :user_id, null: false
      t.integer :review_id, null: false
      t.string :vote_type
      t.string :report_reason
      t.string :comment
      t.string :reporter_ip_address
      t.timestamps
    end

    add_index :spree_review_votes, :review_id
    add_index :spree_review_votes, :user_id
  end
end
