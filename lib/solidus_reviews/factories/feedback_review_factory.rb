# frozen_string_literal: true

FactoryBot.define do
  factory :feedback_review, class: Spree::FeedbackReview do |_f|
    user
    review
    rating { rand(1..5) }
  end
end
