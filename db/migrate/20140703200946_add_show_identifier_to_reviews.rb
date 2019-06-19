# frozen_string_literal: true

class AddShowIdentifierToReviews < SolidusSupport::Migration[4.2]
  def change
    add_column :spree_reviews, :show_identifier, :boolean, default: true
    add_index :spree_reviews, :show_identifier
  end
end
