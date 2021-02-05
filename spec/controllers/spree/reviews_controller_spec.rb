# frozen_string_literal: true

require 'spec_helper'

describe Spree::ReviewsController, type: :controller do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:review) { create(:review, :approved, product: product, user: user) }
  let(:review_params) do
    { product_id: product.slug,
      review: { rating: 3,
                name: 'Ryan Bigg',
                title: 'Great Product',
                review: 'Some big review text..',
                images: [
                  fixture_file_upload(File.new('spec/fixtures/thinking-cat.jpg'))
                ] } }
  end

  before do
    allow(controller).to receive(:spree_current_user).and_return(user)
    allow(controller).to receive(:spree_user_signed_in?).and_return(true)
  end

  describe '#index' do
    context 'for a product that does not exist' do
      it 'responds with a 404' do
        expect {
          get :index, params: { product_id: 'not_real' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'for a valid product' do
      it 'list approved reviews' do
        approved_reviews = [
          create(:review, :approved, product: product),
          create(:review, :approved, product: product)
        ]
        get :index, params: { product_id: product.slug }
        expect(assigns[:approved_reviews]).to match_array approved_reviews
      end
    end
  end

  describe '#new' do
    context 'for a product that does not exist' do
      it 'responds with a 404' do
        expect {
          get :new, params: { product_id: 'not_real' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'fail if the user is not authorized to create a review' do
      allow(controller).to receive(:authorize!).and_raise(RuntimeError)

      expect {
        post :new, params: { product_id: product.slug }
        assert_match 'ryanbig', response.body
      }.to raise_error RuntimeError
    end

    it 'render the new template' do
      get :new, params: { product_id: product.slug }
      expect(response.status).to eq(200)
      expect(response).to render_template(:new)
    end
  end

  describe '#edit' do
    context 'for a product that does not exist' do
      it 'responds with a 404' do
        expect {
          get :edit, params: { id: review.id, product_id: 'not_real' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'fail if the user is not authorized to edit a review' do
      allow(controller).to receive(:authorize!).and_raise(RuntimeError)

      expect {
        post :edit, params: { id: review.id, product_id: product.slug }
        assert_match 'ryanbig', response.body
      }.to raise_error RuntimeError
    end

    it 'render the edit template' do
      get :edit, params: { id: review.id, product_id: product.slug }
      expect(response.status).to eq(200)
      expect(response).to render_template(:edit)
    end

    it 'doesn\'t allow another user to update a users review' do
      other_user = create(:user)
      allow(controller).to receive(:spree_current_user).and_return(other_user)
      get :edit, params: { id: review.id, product_id: product.slug }
      expect(response).not_to render_template(:edit)
      expect(flash[:error]).to eq "Authorization Failure"
    end
  end

  describe '#create' do
    before { allow(controller).to receive(:spree_current_user).and_return(user) }

    context 'for a product that does not exist' do
      it 'responds with a 404' do
        expect {
          post :create, params: { product_id: 'not_real' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'creates a new review' do
      expect {
        post :create, params: review_params
      }.to change(Spree::Review, :count).by(1)
    end

    it 'creates a rating only review' do
      review_params = {
        product_id: product.slug,
        review: { rating: 3 }
      }

      expect {
        post :create, params: review_params
      }.to change(Spree::Review, :count).by(1)
    end

    it 'sets the ip-address of the remote' do
      @request.env['REMOTE_ADDR'] = '127.0.0.1'
      post :create, params: review_params
      expect(assigns[:review].ip_address).to eq '127.0.0.1'
    end

    it 'attaches the image' do
      post :create, params: review_params
      expect(assigns[:review].images).to be_present
    end

    it 'fails if the user is not authorized to create a review' do
      allow(controller).to receive(:authorize!).and_raise(RuntimeError)

      expect{
        post :create, params: review_params
      }.to raise_error RuntimeError
    end

    it 'flashes the notice' do
      post :create, params: review_params
      expect(flash[:notice]).to eq I18n.t('spree.review_successfully_submitted')
    end

    it 'redirects to product page' do
      post :create, params: review_params
      expect(response).to redirect_to spree.product_path(product)
    end

    it 'removes all non-numbers from ratings param' do
      post :create, params: review_params
      expect(controller.params[:review][:rating]).to eq '3'
    end

    it 'sets the current spree user as reviews user' do
      post :create, params: review_params
      review_params[:review][:user_id] = user.id
      assigns[:review][:user_id] = user.id
      expect(assigns[:review][:user_id]).to eq user.id
    end

    context 'with invalid params' do
      it 'renders new when review.save fails' do
        expect_any_instance_of(Spree::Review).to receive(:save).and_return(false)
        post :create, params: review_params
        expect(response).to render_template :new
      end

      it 'does not create a review' do
        expect(Spree::Review.count).to eq 0
        post :create, params: review_params.merge(review: { rating: 'not_a_number' })
        expect(Spree::Review.count).to eq 0
      end
    end

    # It always sets the locale so preference pointless
    context 'when config requires locale tracking:' do
      it 'sets the locale' do
        stub_spree_preferences(Spree::Reviews::Config, track_locale: true)
        post :create, params: review_params
        expect(assigns[:review].locale).to eq I18n.locale.to_s
      end
    end
  end

  describe '#update' do
    before {
      allow(controller).to receive(:spree_current_user).and_return(user)
      @review_params = {
        product_id: product.slug,
        id: review.id,
        review: { title: 'Amazing Product' }
      }
    }

    context 'for a product that does not exist' do
      it 'responds with a 404' do
        expect {
          post :update, params: { id: review.id, product_id: 'not_real' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'updates a review' do
      post :update, params: @review_params

      expect(assigns[:review].title).to eq 'Amazing Product'
      expect(assigns[:review].product).to eq product
      expect(assigns[:review].user).to eq user
    end

    it 'updates a review to be a rating only review' do
      post :update, params: {
        product_id: product.slug,
        id: review.id,
        review: { title: '', review: '', rating: 5 }
      }

      expect(assigns[:review].title).to eq ''
      expect(assigns[:review].review).to eq ''
      expect(assigns[:review].rating).to eq 5
    end

    it 'updates the attached image' do
      post :update, params: {
        product_id: product.slug,
        id: review.id,
        review: {
          images: [
            fixture_file_upload(File.new('spec/fixtures/thinking-cat.jpg')),
          ]
        }
      }
      expect(assigns[:review].images.count).to eq 1
    end

    it 'fails if the user is not authorized to create a review' do
      allow(controller).to receive(:authorize!).and_raise(RuntimeError)

      expect{
        post :update, params: @review_params
      }.to raise_error RuntimeError
    end

    it 'flashes the notice' do
      post :update, params: @review_params

      expect(flash[:notice]).to eq I18n.t('spree.review_successfully_submitted')
    end

    it 'redirects to product page' do
      post :update, params: @review_params
      review.reload
      review.valid?
      expect(response).to redirect_to spree.product_path(product)
    end

    it 'removes all non-numbers from ratings param' do
      @review_params[:review][:rating] = 5
      post :update, params: @review_params
      expect(controller.params[:review][:rating]).to eq '5'
    end

    it 'doesnt change the current spree user as reviews user' do
      post :update, params: @review_params
      expect(assigns[:review].user_id).to eq user.id
    end

    context 'with invalid params' do
      it 'renders edit when review.save fails' do
        expect_any_instance_of(Spree::Review).to receive(:update).and_return(false)
        post :update, params: @review_params
        expect(response).to render_template :edit
      end

      it 'does not update a review' do
        original_rating = review.rating
        original_title = review.title
        @review_params[:review][:rating] = 'not_a_number'
        @review_params[:review][:title] = true
        post :update, params: @review_params

        review.reload
        expect(review.rating).to eq original_rating
        expect(review.title).to eq original_title
      end
    end
  end
end
