# frozen_string_literal: true

class Spree::Review < Spree::Base
  belongs_to :product, touch: true, optional: true
  belongs_to :user, class_name: Spree.user_class.to_s, optional: true
  belongs_to :store
  has_many :review_votes, dependent: :destroy
  has_many :images, -> { order(:position) }, as: :viewable,
    dependent: :destroy, class_name: "Spree::Image"

  before_save :verify_purchaser
  before_save :approve_review, unless: :approved?
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
  scope :preview, -> { oldest_first.limit(Spree::Reviews::Config[:preview_size]) }
  scope :approved, -> { where(approved: true) }
  scope :not_approved, -> { where(approved: false) }
  scope :default_approval_filter, -> { Spree::Reviews::Config[:include_unapproved_reviews] ? all : approved }

  self.allowed_ransackable_associations = %w[product user]
  self.allowed_ransackable_attributes = %w[approved name review title]

  def recalculate_product_rating
    product.recalculate_rating if product.present?
  end

  def email
    user&.email
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

  def star_only?
    [title, review].all?(&:blank?) && rating.present?
  end

  def approve_review
    # Checks if we should auto approve the review.
    if Spree::Reviews::Config[:approve_star_only]
      self.approved = true if star_only?
    elsif Spree::Reviews::Config[:approve_star_only_for_verified_purchaser]
      self.approved = true if star_only? && verified_purchaser?
    end
  end
end