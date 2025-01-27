# frozen_string_literal: true

require 'solidus_reviews_helper'

require "cancan/matchers"

RSpec.describe Spree::ReviewsAbility do
  describe '.allow_anonymous_reviews?' do
    it 'depends on Spree::Reviews::Config[:require_login]' do
      stub_spree_preferences(Spree::Reviews::Config, require_login: false)
      expect(described_class.allow_anonymous_reviews?).to be true
      stub_spree_preferences(Spree::Reviews::Config, require_login: true)
      expect(described_class.allow_anonymous_reviews?).to be false
    end
  end

  context 'permissions' do
    let(:user_without_email) { double(:user, email: nil) }
    let(:user_with_email) { double(:user, email: 'a@b.com') }

    context 'when anonymous reviews are allowed' do
      before do
        stub_spree_preferences(Spree::Reviews::Config, require_login: false)
      end

      it 'lets anyone create a review' do
        [user_without_email, user_with_email].each do |u|
          expect(described_class.new(u)).to be_able_to(:create, Spree::Review.new)
        end
      end
    end

    context 'when anonymous reviews are not allowed' do
      before do
        stub_spree_preferences(Spree::Reviews::Config, require_login: true)
      end

      it 'only allows users with an email to create a review' do
        expect(described_class.new(user_without_email)).not_to be_able_to(:create, Spree::Review.new)

        expect(described_class.new(user_with_email)).to be_able_to(:create, Spree::Review.new)
      end
    end
  end
end
