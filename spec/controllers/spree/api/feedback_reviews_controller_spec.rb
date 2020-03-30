# frozen_string_literal: true

require 'spec_helper'

describe Spree::Api::FeedbackReviewsController, type: :controller do
  render_views

  let!(:user) { create(:user) }
  let!(:review) { create(:review) }
  let!(:feedback_review) { create(:feedback_review, review: review) }

  before do
    user.generate_spree_api_key!
  end

  describe '#create' do
    subject do
      params = { review_id: review.id, token: user.spree_api_key, format: 'json' }.merge(feedback_review_params)
      post :create, params: params
      JSON.parse(response.body)
    end

    let(:feedback_review_params) do
      {
        "feedback_review": {
          "rating": "5",
          "comment": "I agree with what you said"
        }
      }
    end

    context 'when user has already left feedback on a reviewed this product' do
      before do
        feedback_review.update(user_id: user.id)
      end

      it 'returns with a fail' do
        expect(subject["error"]).not_to be_empty
        expect(subject["error"]).to match(/invalid resource/i)
      end
    end

    context 'when it is a users first feedback for a review' do
      it 'returns success with feedback' do
        expect(subject).not_to be_empty
        expect(subject["review_id"]).to eq(review.id)
        expect(subject["rating"]).to eq(5)
        expect(subject["comment"]).to eq("I agree with what you said")
      end

      it 'updates the review' do
        expect(review).to receive(:touch)
        feedback = create(:feedback_review, review: review)
        feedback.save!
      end
    end
  end

  describe '#update' do
    subject do
      put :update, params: params
      JSON.parse(response.body)
    end

    before { feedback_review.update(user_id: user.id) }

    let(:params) { { review_id: review.id, id: feedback_review.id, token: user.spree_api_key, format: 'json' }.merge(feedback_review_params) }

    let(:feedback_review_params) do
      {
        "feedback_review": {
          "rating": "1",
          "comment": "Actually I don't agree"
        }
      }
    end

    context 'when a user updates their own feedback for a review' do
      it 'successfully updates their feedback' do
        original = feedback_review
        expect(subject["id"]).to eq(original.id)
        expect(subject["user_id"]).to eq(original.user_id)
        expect(subject["review_id"]).to eq(original.review_id)
        expect(subject["rating"]).to eq(1)
        expect(subject["comment"]).to eq("Actually I don't agree")
      end
    end

    context 'when a user updates another users review' do
      let(:other_user) { create(:user) }
      let(:params) { { review_id: review.id, id: feedback_review.id, token: other_user.spree_api_key, format: 'json' }.merge(feedback_review_params) }

      before do
        other_user.generate_spree_api_key!
      end

      it 'returns an error' do
        expect(subject["error"]).not_to be_empty
        expect(subject["error"]).to match(/not authorized/i)
      end
    end
  end

  describe '#destroy' do
    subject do
      delete :destroy, params: params
      JSON.parse(response.body)
    end

    before { feedback_review.update(user_id: user.id) }

    let(:params) { { review_id: review.id, id: feedback_review.id, token: user.spree_api_key, format: 'json' } }

    context "when a user destroys their own feedback" do
      it 'returns the deleted feedback' do
        expect(subject["id"]).to eq(feedback_review.id)
        expect(subject["review_id"]).to eq(review.id)
        expect(Spree::FeedbackReview.find_by(id: feedback_review.id)).to be_falsey
      end
    end

    context "when a user destroys another users feedback" do
      let(:other_user) { create(:user) }
      let(:params) { { review_id: review.id, id: feedback_review.id, token: other_user.spree_api_key, format: 'json' } }

      before do
        other_user.generate_spree_api_key!
      end

      it 'returns an error' do
        expect(subject["error"]).not_to be_empty
        expect(subject["error"]).to match(/not authorized/i)
      end
    end
  end
end
