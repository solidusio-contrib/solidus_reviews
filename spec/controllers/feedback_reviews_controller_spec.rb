require 'spec_helper'

describe Spree::FeedbackReviewsController do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:review) { create(:review, user: user) }
  let(:valid_attributes) do
    { review_id: review.id,
      user_id: user.id,
      feedback_review: {
        rating: '4 stars',
        comment: 'some comment'
      }}
  end

  before do
    controller.stub spree_current_user: user
    controller.stub spree_user_signed_in?: true
    request.env['HTTP_REFERER'] = '/'
  end

  describe '#create' do
    it 'creates a new feedback review' do
      rating = 4
      comment = FFaker::Lorem.paragraphs(3).join("\n")
      expect {
        post :create, { review_id: review.id,
                        feedback_review: {
                          comment: comment,
                          rating: rating },
                        format: :js }
        expect(response.status).to eq(200)
        expect(response).to render_template(:create)
      }.to change(Spree::Review, :count).by(1)
      feedback_review = Spree::FeedbackReview.last
      expect(feedback_review.comment).to eq(comment)
      expect(feedback_review.review).to eq(review)
      expect(feedback_review.rating).to eq(rating)
      expect(feedback_review.user).to eq(user)

    end

    it 'redirects back to the calling page' do
      post :create, valid_attributes
      expect(response).to redirect_to '/'
    end

    it 'sets locale on feedback-review if required by config' do
      Spree::Reviews::Config.preferred_track_locale = true
      post :create, valid_attributes
      expect(assigns[:review].locale).to eq I18n.locale.to_s
    end

    it 'fails when user is not authorized' do
      controller.stub(:authorize!) { raise }
      expect {
        post :create, valid_attributes
      }.to raise_error RuntimeError
    end

    it 'removes all non-numbers from ratings parameter' do
      post :create, valid_attributes
      expect(controller.params[:feedback_review][:rating]).to eq '4'
    end

    it 'do not create feedback-review if review doesnt exist' do
      expect {
        post :create, valid_attributes.merge!({review_id: nil})
      }.to raise_error ActionController::UrlGenerationError
    end
  end
end
