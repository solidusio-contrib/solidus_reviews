# frozen_string_literal: true

class Spree::ReviewsAbility
  include CanCan::Ability

  def initialize(user)
    review_ability_class = self.class

    can :create, Spree::Review do |_review|
      review_ability_class.allow_anonymous_reviews? || !user.email.blank?
    end

    can :create, Spree::FeedbackReview do |_review|
      review_ability_class.allow_anonymous_reviews? || !user.email.blank?
    end

    # You can read your own reviews, and everyone can read approved ones
    can :read, Spree::Review do |review|
      review.user == user || review.approved?
    end

    # You can only change your own review
    can [:update, :destroy], Spree::Review do |review|
      review.user == user
    end
  end

  def self.allow_anonymous_reviews?
    !Spree::Reviews::Config[:require_login]
  end
end
