# frozen_string_literal: true

require 'spec_helper'

require "cancan/matchers"

describe Spree::ReviewsAbility do
  context '.allow_anonymous_reviews?' do
    it 'should depend on Spree::Reviews::Config[:require_login]' do
      Spree::Reviews::Config[:require_login] = false
      expect(Spree::ReviewsAbility.allow_anonymous_reviews?).to be true
      Spree::Reviews::Config[:require_login] = true
      expect(Spree::ReviewsAbility.allow_anonymous_reviews?).to be false
    end
  end

  context 'permissions' do
    let(:user_without_email) { double(:user, email: nil) }
    let(:user_with_email) { double(:user, email: 'a@b.com') }

    context 'when anonymous reviews are allowed' do
      before do
        Spree::Reviews::Config[:require_login] = false
      end

      it 'lets anyone create a review or feedback review' do
        [user_without_email, user_with_email].each do |u|
          expect(Spree::ReviewsAbility.new(u)).to be_able_to(:create, Spree::Review.new)
          expect(Spree::ReviewsAbility.new(u)).to be_able_to(:create, Spree::FeedbackReview.new)
        end
      end
    end

    context 'when anonymous reviews are not allowed' do
      before do
        Spree::Reviews::Config[:require_login] = true
      end

      it 'only allows users with an email to create a review or feedback review' do
        expect(Spree::ReviewsAbility.new(user_without_email)).to_not be_able_to(:create, Spree::Review.new)
        expect(Spree::ReviewsAbility.new(user_without_email)).to_not be_able_to(:create, Spree::FeedbackReview.new)

        expect(Spree::ReviewsAbility.new(user_with_email)).to be_able_to(:create, Spree::Review.new)
        expect(Spree::ReviewsAbility.new(user_with_email)).to be_able_to(:create, Spree::FeedbackReview.new)
      end
    end
  end
end
