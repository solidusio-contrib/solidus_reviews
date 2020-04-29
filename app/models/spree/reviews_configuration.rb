# frozen_string_literal: true

class Spree::ReviewsConfiguration < Spree::Preferences::Configuration
  def self.boolean_preferences
    %w(display_unapproved_reviews include_unapproved_reviews feedback_rating show_email require_login track_locale allow_image_upload)
  end

  # include non-approved reviews in (public) listings
  preference :include_unapproved_reviews, :boolean, default: false

  # displays non-approved reviews in (public) listings
  preference :display_unapproved_reviews, :boolean, default: false

  # control how many reviews are shown in summaries etc.
  preference :preview_size, :integer, default: 3

  # show a reviewer's email address
  preference :show_email, :boolean, default: false

  # show if a reviewer actually purchased the product
  preference :show_verified_purchaser, :boolean, default: false

  # show helpfullness rating form elements
  preference :feedback_rating, :boolean, default: false

  # require login to post reviews
  preference :require_login, :boolean, default: true

  # whether to keep track of the reviewer's locale
  preference :track_locale, :boolean, default: false

  # render checkbox for a user to approve to show their identifier (name or email) on their review
  preference :render_show_identifier_checkbox, :boolean, default: false

  # Approves star only reviews automatically (Reviews without a Title/Review)
  preference :approve_star_only, :boolean, default: false

  # Approves star only reviews for verified purchasers only.
  preference :approve_star_only_for_verified_purchaser, :boolean, default: false

  # allow customer to update image with the review
  preference :allow_image_upload, :boolean, default: true
end
