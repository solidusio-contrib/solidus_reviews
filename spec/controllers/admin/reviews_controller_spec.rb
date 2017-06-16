require 'spec_helper'

describe Spree::Admin::ReviewsController do
  stub_authorization!

  let(:product) { create(:product) }
  let(:review) { create(:review, approved: false) }

  before do
    user = create(:admin_user)
    controller.stub(try_spree_current_user: user)
  end

  context '#index' do
    it 'list reviews' do
      reviews = [
        create(:review, product: product),
        create(:review, product: product)
      ]
      get :index, params: { product_id: product.slug }
      expect(assigns[:reviews]).to match_array reviews
    end
  end

  context '#approve' do
    it 'show notice message when approved' do
      review.update_attribute(:approved, true)
      get :approve, params: { id: review.id }
      expect(response).to redirect_to spree.admin_reviews_path
      expect(flash[:success]).to eq Spree.t(:info_approve_review)
    end

    it 'show error message when not approved' do
      Spree::Review.any_instance.stub(:update_attribute).and_return(false)
      get :approve, params: { id: review.id }
      expect(flash[:error]).to eq Spree.t(:error_approve_review)
    end
  end

  context '#edit' do
    specify do
      get :edit, params: { id: review.id }
      expect(response.status).to eq(200)
    end

    context 'when product is nil' do
      before do
        review.product = nil
        review.save!
      end

      it 'flash error' do
        get :edit, params: { id: review.id }
        expect(flash[:error]).to eq Spree.t(:error_no_product)
      end

      it 'redirect to admin-reviews page' do
        get :edit, params: { id: review.id }
        expect(response).to redirect_to spree.admin_reviews_path
      end
    end
  end
end
