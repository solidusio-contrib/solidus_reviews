module Spree
  module Api
    class ReviewsController < Spree::Api::BaseController
      respond_to :json

      before_action :load_review, only: [:show, :update, :destroy]
      before_action :load_product, :find_review_user
      before_action :sanitize_rating, only: [:create, :update]
      before_action :prevent_multiple_reviews, only: [:create]

      def index
        if @product
          @reviews = Spree::Review.default_approval_filter.where(product: @product)
        else
          @reviews = Spree::Review.where(user: @current_api_user)
        end

        respond_with(@reviews)
      end

      def show
        authorize! :read, @review
        render json: @review, include: [:images, :feedback_reviews]
      end

      def create
        return not_found if @product.nil?

        @review = Spree::Review.new(review_params)
        @review.product = @product
        @review.user = @current_api_user
        @review.ip_address = request.remote_ip
        @review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]

        authorize! :create, @review
        if @review.save
          render json: @review, include: [:images, :feedback_reviews], status: 201
        else
          invalid_resource!(@review)
        end
      end

      def update
        authorize! :update, @review

        attributes = review_params.merge(ip_address: request.remote_ip, approved: false)

        if @review.update(attributes)
          render json: @review, include: [:images, :feedback_reviews], status: 200
        else
          invalid_resource!(@review)
        end
      end

      def destroy
        authorize! :destroy, @review

        if @review.destroy
          render json: @review, status: 200
        else
          invalid_resource!(@review)
        end
      end

      private

      def permitted_review_attributes
        [:product_id, :rating, :title, :review, :name, :show_identifier]
      end

      def review_params
        params.permit(permitted_review_attributes)
      end

      # Loads product from product id.
      def load_product
        if params[:product_id]
          @product = Spree::Product.friendly.find(params[:product_id])
        else
          @product = @review&.product
        end
      end

      # Finds user based on api_key or by user_id if api_key belongs to an admin.
      def find_review_user
        if params[:user_id] && @current_user_roles.include?('admin')
          @current_api_user = Spree.user_class.find(params[:user_id])
        end
      end

      # Loads any review that is shared between the user and product
      def load_review
        @review = Spree::Review.find(params[:id])
      end

      # Ensures that a user can't create more than 1 review per product
      def prevent_multiple_reviews
        @review = @current_api_user.reviews.find_by(product: @product)
        if @review.present?
          invalid_resource!(@review)
        end
      end

      # Converts rating strings like "5 units" to "5"
      # Operates on params
      def sanitize_rating
        params[:rating].sub!(/\s*[^0-9]*\z/, '') unless params[:rating].blank?
      end
    end
  end
end
