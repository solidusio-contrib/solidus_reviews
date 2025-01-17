# frozen_string_literal: true

require 'solidus_reviews_helper'

RSpec.describe Spree::ReviewVote do
  let(:review) { create(:review, positive_count: 0, negative_count: 0, flag_count: 0) }
  let(:user) { create(:user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      vote = described_class.new(user: user, review: review, vote_type: Spree::ReviewVote::POSITIVE)
      expect(vote).to be_valid
    end

    it 'is invalid without a valid vote_type' do
      vote = described_class.new(user: user, review: review, vote_type: 'InvalidType')
      expect(vote).not_to be_valid
      expect(vote.errors[:vote_type]).to include('is not included in the list')
    end

    it 'disallows updating the vote_type to the same value' do
      vote = create(:review_vote, user: user, review: review, vote_type: Spree::ReviewVote::POSITIVE)
      vote.vote_type = Spree::ReviewVote::POSITIVE
      expect(vote).not_to be_valid
      expect(vote.errors[:vote_type]).to include('has already been set to this value')
    end
  end

  describe 'callbacks' do
    context 'when creating a new vote' do
      it 'increments the positive count for a positive vote' do
        expect {
          create(:review_vote, user: user, review: review, vote_type: Spree::ReviewVote::POSITIVE)
        }.to change { review.reload.positive_count }.by(1)
      end

      it 'increments the negative count for a negative vote' do
        expect {
          create(:review_vote, user: user, review: review, vote_type: Spree::ReviewVote::NEGATIVE)
        }.to change { review.reload.negative_count }.by(1)
      end

      it 'increments the flag count for a report vote' do
        expect {
          create(:review_vote, user: user, review: review, vote_type: Spree::ReviewVote::REPORT, report_reason: 'Spam')
        }.to change { review.reload.flag_count }.by(1)
      end
    end

    context 'when updating an existing vote' do
      let!(:vote) { create(:review_vote, user: user, review: review, vote_type: Spree::ReviewVote::POSITIVE) }

      it 'adjusts the counters when vote_type changes from positive to negative' do
        expect {
          vote.update(vote_type: Spree::ReviewVote::NEGATIVE)
        }.to change { review.reload.positive_count }.by(-1)
         .and change { review.reload.negative_count }.by(1)
      end

      it 'adjusts the counters when vote_type changes from positive to report' do
        expect {
          vote.update(vote_type: Spree::ReviewVote::REPORT, report_reason: 'Spam')
        }.to change { review.reload.positive_count }.by(-1)
         .and change { review.reload.flag_count }.by(1)
      end

      it 'does not adjust counters if vote_type remains unchanged' do
        expect {
          vote.update(vote_type: Spree::ReviewVote::POSITIVE)
        }.not_to(change { review.reload.positive_count })
      end
    end
  end

  describe '#adjust_vote_count' do
    it 'decrements the previous vote and increments the new vote' do
      vote = create(:review_vote, user: user, review: review, vote_type: Spree::ReviewVote::POSITIVE)
      expect {
        vote.adjust_vote_count(previous_vote: Spree::ReviewVote::POSITIVE, current_vote: Spree::ReviewVote::NEGATIVE)
      }.to change { review.reload.positive_count }.by(-1)
       .and change { review.reload.negative_count }.by(1)
    end
  end
end
