# frozen_string_literal: true

json.cache! [I18n.locale, review] do
  json.(review, *review_attributes)
  json.images(review.images) do |image|
    json.partial!("spree/api/images/image", image: image)
  end
  json.feedback_reviews(review.feedback_reviews) do |feedback_review|
    json.partial!("spree/api/reviews/feedback_review", feedback_review: feedback_review)
  end
end
