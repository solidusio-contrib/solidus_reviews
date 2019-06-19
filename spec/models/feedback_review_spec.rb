# frozen_string_literal: true

require 'spec_helper'

describe Spree::FeedbackReview do
  context 'validations' do
    it 'validates by default' do
      expect(build(:feedback_review)).to be_valid
    end

    it 'validates with a nil user' do
      expect(build(:feedback_review, user: nil)).to be_valid
    end

    it 'does not validate with a nil review' do
      expect(build(:feedback_review, review: nil)).to_not be_valid
    end

    context 'rating' do
      it 'does not validate when no rating is specified' do
        expect(build(:feedback_review, rating: nil)).to_not be_valid
      end

      it 'does not validate when the rating is not a number' do
        expect(build(:feedback_review, rating: 'not_a_number')).to_not be_valid
      end

      it 'does not validate when the rating is a float' do
        expect(build(:feedback_review, rating: 2.718)).to_not be_valid
      end

      it 'does not validate when the rating is less than 1' do
        expect(build(:feedback_review, rating: 0)).to_not be_valid
        expect(build(:feedback_review, rating: -5)).to_not be_valid
      end

      it 'does not validate when the rating is greater than 5' do
        expect(build(:feedback_review, rating: 6)).to_not be_valid
        expect(build(:feedback_review, rating: 8)).to_not be_valid
      end

      (1..5).each do |i|
        it "validates when the rating is #{i}" do
          expect(build(:feedback_review, rating: i)).to be_valid
        end
      end
    end
  end

  context 'scopes' do
    context 'most_recent_first' do
      let!(:feedback_review_1) { create(:feedback_review, created_at: 10.days.ago) }
      let!(:feedback_review_2) { create(:feedback_review, created_at: 2.days.ago) }
      let!(:feedback_review_3) { create(:feedback_review, created_at: 5.days.ago) }

      it 'properly runs most_recent_first queries' do
        expect(Spree::FeedbackReview.most_recent_first.to_a).to eq([feedback_review_2, feedback_review_3, feedback_review_1])
      end

      it 'defaults to most_recent_first queries' do
        expect(Spree::FeedbackReview.all.to_a).to eq([feedback_review_2, feedback_review_3, feedback_review_1])
      end
    end

    context 'localized' do
      let!(:en_feedback_review_1) { create(:feedback_review, locale: 'en', created_at: 10.days.ago) }
      let!(:en_feedback_review_2) { create(:feedback_review, locale: 'en', created_at: 2.days.ago) }
      let!(:en_feedback_review_3) { create(:feedback_review, locale: 'en', created_at: 5.days.ago) }

      let!(:es_feedback_review_1) { create(:feedback_review, locale: 'es', created_at: 10.days.ago) }
      let!(:fr_feedback_review_1) { create(:feedback_review, locale: 'fr', created_at: 10.days.ago) }

      it 'properly runs localized queries' do
        expect(Spree::FeedbackReview.localized('en').to_a).to eq([en_feedback_review_2, en_feedback_review_3, en_feedback_review_1])
        expect(Spree::FeedbackReview.localized('es').to_a).to eq([es_feedback_review_1])
        expect(Spree::FeedbackReview.localized('fr').to_a).to eq([fr_feedback_review_1])
      end
    end
  end
end
