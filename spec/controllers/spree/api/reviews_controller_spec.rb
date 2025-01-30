# frozen_string_literal: true

require 'solidus_reviews_helper'

RSpec.describe Spree::Api::ReviewsController, type: :controller do
  routes { Spree::Core::Engine.routes }
  render_views

  let!(:user) { create(:user) }
  let(:store) { create(:store) }
  let!(:review) { create(:review, rating: 5, store: store) }
  let!(:product) { review.product }

  before do
    user.generate_spree_api_key!
    Array.new(3).each do
      create(:review)
    end
  end

  describe '#index' do
    context 'when given a product_id' do
      subject do
        get :index, params: { product_id: product.id, token: user.spree_api_key, format: 'json' }
        JSON.parse(response.body)
      end

      context 'there are no reviews for a product' do
        it 'returns an empty array' do
          expect(Spree::Review.count).to be >= 0
          expect(subject["reviews"]).to be_empty
        end
      end

      context 'there are reviews for the product and other products' do
        it 'returns all approved reviews for the product' do
          review.update(approved: true)
          review.images << create(:image)
          expect(Spree::Review.count).to be >= 2
          expect(subject.size).to eq(2)
          expect(subject["reviews"][0]["id"]).to eq(review.id)
          expect(subject["reviews"][0]["images"].count).to eq(1)
          expect(subject["reviews"][0]["verified_purchaser"]).to eq(false)
          expect(subject["avg_rating"]).to eq("5.0")
        end
      end
    end

    context 'when given a user_id' do
      subject do
        get :index, params: { user_id: user.id, token: user.spree_api_key, format: 'json' }
        JSON.parse(response.body)
      end

      context 'there are no reviews for the user' do
        it 'returns an empty array' do
          expect(Spree::Review.count).to be >= 0
          expect(subject["reviews"]).to be_empty
        end
      end

      context 'there are reviews for user' do
        before { review.update(user_id: user.id) }

        it 'returns all reviews for the user' do
          expect(Spree::Review.count).to be >= 2
          expect(subject.size).to eq(2)
          expect(subject["reviews"][0]["id"]).to eq(review.id)
          expect(subject["avg_rating"]).to eq(nil)
        end
      end
    end
  end

  describe '#show' do
    subject do
      get :show, params: { id: review.id, token: user.spree_api_key, format: 'json' }
      JSON.parse(response.body)
    end

    context 'when it is the users review' do
      before { review.update(user_id: user.id) }

      it 'returns the review' do
        expect(subject).not_to be_empty
        expect(subject["product_id"]).to eq(product.id)
        expect(subject["name"]).to eq(review[:name])
        expect(subject["review"]).to eq(review[:review])
        expect(subject["title"]).to eq(review[:title])
        expect(subject["verified_purchaser"]).to eq(false)
        expect(subject["images"]).to eq([])
      end
    end

    context 'when it is not the users review' do
      it 'returns with not authorized' do
        expect(subject["error"]).not_to be_empty
        expect(subject["error"]).to match(/not authorized/i)
      end

      context 'and it the review is approved' do
        before { review.update(approved: true) }

        it 'returns the review' do
          expect(subject).not_to be_empty
          expect(subject["product_id"]).to eq(product.id)
          expect(subject["name"]).to eq(review[:name])
          expect(subject["review"]).to eq(review[:review])
          expect(subject["title"]).to eq(review[:title])
          expect(subject["images"]).to eq([])
        end
      end
    end
  end

  describe '#create' do
    subject do
      params = { product_id: product.id, token: user.spree_api_key, format: 'json' }.merge(review_params)
      post :create, params: params
      JSON.parse(response.body)
    end

    let(:review_params) do
      {
        "user_id": user.id,
        "rating": "3 stars",
        "title": "My title 2",
        "name": "Full Name",
        "review": "My review of the product"
      }
    end

    context 'when user has already reviewed this product' do
      before do
        review.update(user_id: user.id)
      end

      it 'returns with a fail' do
        expect(subject["error"]).not_to be_empty
        expect(subject["error"]).to match(/invalid resource/i)
      end
    end

    context 'when it is a users first review for the product' do
      it 'returns success with review' do
        expect(subject).not_to be_empty
        expect(subject["product_id"]).to eq(product.id)
        expect(subject["name"]).to eq(review_params[:name])
        expect(subject["review"]).to eq(review_params[:review])
        expect(subject["title"]).to eq(review_params[:title])
        expect(subject["images"]).to eq([])
      end
    end
  end

  describe '#update' do
    subject do
      put :update, params: params
      JSON.parse(response.body)
    end

    before { review.update(approved: true, user_id: user.id) }

    let(:params) { { product_id: product.id, id: review.id, token: user.spree_api_key, format: 'json' }.merge(review_params) }

    let(:review_params) do
      {
        "rating": "3 stars",
        "title": "My title 2",
        "name": "Full name",
        "review": "My review of the product",
      }
    end

    context 'when a user updates their own review' do
      it 'successfullies update the review and set approved back to false' do
        original = review
        expect(original.approved?).to be true
        expect(subject["id"]).to eq(original.id)
        expect(subject["user_id"]).to eq(original.user_id)
        expect(subject["product_id"]).to eq(original.product_id)
        expect(subject["approved"]).to be false
        expect(subject["images"]).to eq([])
      end
    end

    context 'when a user updates another users review' do
      let(:other_user) { create(:user) }
      let(:params) { { product_id: product.id, id: review.id, token: other_user.spree_api_key, format: 'json' }.merge(review_params) }

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

    before { review.update(approved: true, user_id: user.id) }

    let(:params) { { product_id: product.id, id: review.id, token: user.spree_api_key, format: 'json' } }

    context "when a user destroys their own review" do
      it 'returns the deleted review' do
        expect(subject["id"]).to eq(review.id)
        expect(subject["product_id"]).to eq(product.id)
        expect(Spree::Review.find_by(id: review.id)).to be_falsey
      end
    end

    context "when a user destroys another users review" do
      let(:other_user) { create(:user) }
      let(:params) { { product_id: product.id, id: review.id, token: other_user.spree_api_key, format: 'json' } }

      before do
        other_user.generate_spree_api_key!
      end

      it 'returns an error' do
        expect(subject["error"]).not_to be_empty
        expect(subject["error"]).to match(/not authorized/i)
      end
    end
  end

  describe 'POST #set_positive_vote' do
    context 'when the vote update is successful' do
      let!(:vote) { create(:review_vote, :negative, review: review, user: user) }

      it 'marks the review as positive' do
        post :set_positive_vote, params: { id: review.id, token: user.spree_api_key, format: 'json' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Review marked as positive.')
        expect(json_response['positive_count']).to eq(review.reload.positive_count)
        expect(vote.reload.vote_type).to eq(Spree::ReviewVote::POSITIVE)
        expect(vote.report_reason).to be_nil
        expect(review.reload.positive_count).to eq(1)
      end
    end
  end

  describe 'POST #set_negative_vote' do
    context 'when the vote update is successful' do
      let!(:vote) { create(:review_vote, review: review, user: user) }

      it 'marks the review as negative' do
        post :set_negative_vote, params: { id: review.id, token: user.spree_api_key, format: 'json' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Review marked as negative.')
        expect(json_response['negative_count']).to eq(review.reload.negative_count)
        expect(vote.reload.vote_type).to eq(Spree::ReviewVote::NEGATIVE)
        expect(vote.report_reason).to be_nil
        expect(review.reload.negative_count).to eq(1)
      end
    end
  end

  describe 'POST #flag_review' do
    context 'when the vote update is successful' do
      let!(:vote) { create(:review_vote, review: review, user: user) }

      it 'marks the review as flagged' do
        post :flag_review, params: { id: review.id, token: user.spree_api_key, report_reason: 'Abusive Content', format: 'json' }

        expect(response).to have_http_status(:ok)
        expect(vote.reload.vote_type).to eq(Spree::ReviewVote::REPORT)
        expect(vote.reload.report_reason).to eq('Abusive Content')
        expect(JSON.parse(response.body)['message']).to eq('Review marked as flagged.')
        expect(review.reload.flag_count).to eq(1)
      end
    end
  end
end
