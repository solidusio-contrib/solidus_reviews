# frozen_string_literal: true

class AddLocaleToReviews < SolidusSupport::Migration[4.2]
  def self.up
    add_column :spree_reviews, :locale, :string, default: 'en'
  end

  def self.down
    remove_column :spree_reviews, :locale
  end
end
