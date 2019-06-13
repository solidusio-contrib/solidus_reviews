class AddVerifiedPurchaserToReviews < SolidusSupport::Migration[4.2]
  def change
    add_column :spree_reviews, :verified_purchaser, :boolean, default: false
  end
end
