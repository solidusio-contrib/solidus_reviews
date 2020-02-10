# frozen_string_literal: true

module Spree
  module Api
    class FeedbackReviewsController < Spree::Api::BaseController
      respond_to :json

      before_action :load_review, :load_feedback_review, only: [:create, :update, :destroy]
      before_action :load_product, :find_review_user
      before_action :sanitize_rating, only: [:create, :update]
      before_action :prevent_multiple_reviews, only: [:create]

      def create
        return not_found if @product.nil?

        if @review.present?
          @feedback_review = @review.feedback_reviews.new(feedback_review_params)
          @feedback_review.user = @current_api_user
          @feedback_review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]
        end

        authorize! :create, @feedback_review
        if @feedback_review.save
          render json: @feedback_review
        else
          invalid_resource!(@feedback_review)
        end
      end

      def update
        authorize! :update, @feedback_review

        if @feedback_review.update(feedback_review_params)
          render json: @feedback_review, status: :ok
        else
          invalid_resource!(@feedback_review)
        end
      end

      def destroy
        authorize! :destroy, @feedback_review

        if @feedback_review.destroy
          render json: @feedback_review, status: :ok
        else
          invalid_resource!(@feedback_review)
        end
      end

      private

      def permitted_feedback_review_attributes
        [:rating, :comment]
      end

      def feedback_review_params
        params.require(:feedback_review).permit(permitted_feedback_review_attributes)
      end

      # Loads product from product id.
      def load_product
        @product = if params[:product_id]
                     Spree::Product.friendly.find(params[:product_id])
                   else
                     @review&.product
                   end
      end

      # Finds user based on api_key or by user_id if api_key belongs to an admin.
      def find_review_user
        @current_api_user = Spree::User.find(params[:user_id])
      end

      # Loads any review that is shared between the user and product
      def load_review
        @review = Spree::Review.find(params[:review_id])
      end

      def load_feedback_review
        @feedback_review = Spree::FeedbackReview.find(params[:id])
      end

      # Ensures that a user can't leave multiple feedbacks on a single review
      def prevent_multiple_reviews
        @feedbackReview = @review.feedback_reviews.find_by(user_id: @current_api_user)
        if @feedbackReview.present?
          invalid_resource!(@feedbackReview)
        end
      end

      # Converts rating strings like "5 units" to "5"
      # Operates on params
      def sanitize_rating
        params[:feedback_review][:rating].to_s.sub!(/\s*[^0-9]*\z/, '') unless params[:feedback_review] && params[:feedback_review][:rating].blank?
      end
    end
  end
end
