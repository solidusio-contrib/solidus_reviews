FactoryBot.define do
  factory :feedback_review, :class => Spree::FeedbackReview do |f|
    user
    review
    rating  { rand(1..5) }
  end
end
