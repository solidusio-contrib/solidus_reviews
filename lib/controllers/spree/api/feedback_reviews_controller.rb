# frozen_string_literal: true

module Spree
  module Api
    class FeedbackReviewsController < Spree::Api::BaseController
      respond_to :json

      before_action :load_review, only: [:create, :update, :destroy]
      before_action :load_feedback_review, only: [:update, :destroy]
      before_action :find_review_user
      before_action :sanitize_rating, only: [:create, :update]
      before_action :prevent_multiple_feedback_reviews, only: [:create]

      def create
        if @review.present?
          @feedback_review = @review.feedback_reviews.new(feedback_review_params)
          @feedback_review.user = @current_api_user
          @feedback_review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]
        end

        authorize! :create, @feedback_review
        if @feedback_review.save
          render json: @feedback_review, status: :created
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

      # Finds user based on api_key or by user_id if api_key belongs to an admin.
      def find_review_user
        if params[:user_id] && @current_user_roles.include?('admin')
          @current_api_user = Spree.user_class.find(params[:user_id])
        end
      end

      # Loads any review that is shared between the user and product
      def load_review
        @review = Spree::Review.find(params[:review_id])
      end

      # Loads the feedback_review
      def load_feedback_review
        @feedback_review = Spree::FeedbackReview.find(params[:id])
      end

      # Ensures that a user can't leave multiple feedbacks on a single review
      def prevent_multiple_feedback_reviews
        @feedback_review = @review.feedback_reviews.find_by(user_id: @current_api_user)
        if @feedback_review.present?
          invalid_resource!(@feedback_review)
        end
      end

      # Converts rating strings like "5 units" to "5"
      # Operates on params
      def sanitize_rating
        params[:rating].to_s.sub!(/\s*[^0-9]*\z/, '') unless params[:feedback_review] && params[:feedback_review][:rating].blank?
      end
    end
  end
end
