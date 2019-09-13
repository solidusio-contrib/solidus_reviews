# frozen_string_literal: true

class Spree::Review < ActiveRecord::Base
  belongs_to :product, touch: true, optional: true
  belongs_to :user, class_name: Spree.user_class.to_s, optional: true
  has_many   :feedback_reviews
  has_many   :images, -> { order(:position) }, as: :viewable,
    dependent: :destroy, class_name: "Spree::Image"

  before_create :verify_purchaser
  after_save :recalculate_product_rating, if: :approved?
  after_destroy :recalculate_product_rating

  validates :rating, numericality: { only_integer: true,
                                     greater_than_or_equal_to: 1,
                                     less_than_or_equal_to: 5,
                                     message: :you_must_enter_value_for_rating }

  default_scope { order("spree_reviews.created_at DESC") }

  scope :localized, ->(lc) { where('spree_reviews.locale = ?', lc) }
  scope :most_recent_first, -> { order('spree_reviews.created_at DESC') }
  scope :oldest_first, -> { reorder('spree_reviews.created_at ASC') }
  scope :preview, -> { limit(Spree::Reviews::Config[:preview_size]).oldest_first }
  scope :approved, -> { where(approved: true) }
  scope :not_approved, -> { where(approved: false) }
  scope :default_approval_filter, -> { Spree::Reviews::Config[:include_unapproved_reviews] ? all : approved }

  def feedback_stars
    return 0 if feedback_reviews.size <= 0
    ((feedback_reviews.sum(:rating) / feedback_reviews.size) + 0.5).floor
  end

  def recalculate_product_rating
    product.recalculate_rating if product.present?
  end

  def email
    user.try!(:email)
  end

  def verify_purchaser
    return unless user_id && product_id

    verified_purchase = Spree::LineItem.joins(:order, :variant)
      .where.not(spree_orders: { completed_at: nil })
      .find_by(
        spree_variants: { product_id: product_id },
        spree_orders: { user_id: user_id }
      ).present?

    self.verified_purchaser = verified_purchase
  end
end
