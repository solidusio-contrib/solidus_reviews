require 'spec_helper'

describe Spree::Api::ReviewsController, type: :controller do
  render_views

  let!(:user) { create(:user) }
  let!(:review) { create(:review) }
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
        api_get :index, product_id: product.id, token: user.spree_api_key
        JSON.parse(response.body)
      end

      context 'there are no reviews for a product' do
        it 'should return an empty array' do
          expect(Spree::Review.count).to be >= 0
          expect(subject["reviews"]).to be_empty
        end
      end

      context 'there are reviews for the product and other products' do
        it 'returns all approved reviews for the product' do
          review.update(approved: true)
          expect(Spree::Review.count).to be >= 2
          expect(subject.size).to eq(1)
          expect(subject["reviews"][0]["id"]).to eq(review.id)
        end
      end
    end

    context 'when given a user_id' do
      subject do
        api_get :index, user_id: user.id, token: user.spree_api_key
        JSON.parse(response.body)
      end

      context 'there are no reviews for the user' do
        it 'should return an empty array' do
          expect(Spree::Review.count).to be >= 0
          expect(subject["reviews"]).to be_empty
        end
      end

      context 'there are reviews for user' do
        before { review.update(user_id: user.id) }

        it 'returns all reviews for the user' do
          expect(Spree::Review.count).to be >= 2
          expect(subject.size).to eq(1)
          expect(subject["reviews"][0]["id"]).to eq(review.id)
        end
      end
    end
  end

  describe '#show' do
    subject do
      api_get :show, id: review.id, token: user.spree_api_key
      JSON.parse(response.body)
    end

    context 'when it is the users review' do
      before { review.update(user_id: user.id) }

      it 'should return the review' do
        expect(subject).not_to be_empty
        expect(subject["product_id"]).to eq(product.id)
        expect(subject["name"]).to eq(review[:name])
        expect(subject["review"]).to eq(review[:review])
        expect(subject["title"]).to eq(review[:title])
      end
    end

    context 'when it is not the users review' do
      it 'should return with not authorized' do
        expect(subject["error"]).not_to be_empty
        expect(subject["error"]).to match(/not authorized/i)
      end

      context 'and it the review is approved' do
        before { review.update(approved: true) }

        it 'should return the review' do
          expect(subject).not_to be_empty
          expect(subject["product_id"]).to eq(product.id)
          expect(subject["name"]).to eq(review[:name])
          expect(subject["review"]).to eq(review[:review])
          expect(subject["title"]).to eq(review[:title])
        end
      end
    end
  end

  describe '#create' do
    let(:review_params) do
      {
        "user_id": user.id,
        "rating": "3 stars",
        "title": "My title 2",
        "name": "Full Name",
        "review": "My review of the product"
      }
    end

    subject do
      params = { product_id: product.id, token: user.spree_api_key }.merge(review_params)
      api_post :create, params
      JSON.parse(response.body)
    end

    context 'when user has already reviewed this product' do
      before do
        review.update(user_id: user.id)
      end

      it 'should return with a fail' do
        expect(subject["error"]).not_to be_empty
        expect(subject["error"]).to match(/invalid resource/i)
      end
    end

    context 'when it is a users first review for the product' do
      it 'should return success with review' do
        expect(subject).not_to be_empty
        expect(subject["product_id"]).to eq(product.id)
        expect(subject["name"]).to eq(review_params[:name])
        expect(subject["review"]).to eq(review_params[:review])
        expect(subject["title"]).to eq(review_params[:title])
      end
    end
  end

  describe '#update' do
    before { review.update(approved: true, user_id: user.id) }
    let(:params) { { product_id: product.id, id: review.id, token: user.spree_api_key }.merge(review_params) }

    let(:review_params) do
      {
        "rating": "3 stars",
        "title": "My title 2",
        "name": "Full name",
        "review": "My review of the product",
      }
    end

    subject do
      api_put :update, params
      JSON.parse(response.body)
    end

    context 'when a user updates their own review' do
      it 'should successfully update the review and set approved back to false' do
        original = review
        expect(original.approved?).to be true
        expect(subject["id"]).to eq(original.id)
        expect(subject["user_id"]).to eq(original.user_id)
        expect(subject["product_id"]).to eq(original.product_id)
        expect(subject["approved"]).to be false
      end
    end

    context 'when a user updates another persons review' do
      let(:other_user) { create(:user) }
      let(:params) { { product_id: product.id, id: review.id, token: other_user.spree_api_key }.merge(review_params) }

      before do
        other_user.generate_spree_api_key!
      end

      it 'should return an error' do
        expect(subject["error"]).not_to be_empty
        expect(subject["error"]).to match(/not authorized/i)
      end
    end
  end

  describe '#destroy' do
    before { review.update(approved: true, user_id: user.id) }
    let(:params) { { product_id: product.id, id: review.id, token: user.spree_api_key } }

    subject do
      api_delete :destroy, params
      JSON.parse(response.body)
    end

    context "when a user destroys their own review" do
      it 'should return the deleted review' do
        expect(subject["id"]).to eq(review.id)
        expect(subject["product_id"]).to eq(product.id)
        expect(Spree::Review.find_by(id: review.id)).to be_falsey
      end
    end

    context "when a user destroys their own review" do
      let(:other_user) { create(:user) }
      let(:params) { { product_id: product.id, id: review.id, token: other_user.spree_api_key } }

      before do
        other_user.generate_spree_api_key!
      end

      it 'should return an error' do
        expect(subject["error"]).not_to be_empty
        expect(subject["error"]).to match(/not authorized/i)
      end
    end
  end
end
