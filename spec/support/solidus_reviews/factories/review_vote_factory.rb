# frozen_string_literal: true

FactoryBot.define do
  factory :review_vote, class: Spree::ReviewVote do |_f|
    user
    review
    report_reason { nil }
    vote_type { Spree::ReviewVote::POSITIVE }

    trait :negative do
      vote_type { Spree::ReviewVote::NEGATIVE }
    end
  end
end
