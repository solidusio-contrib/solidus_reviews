# frozen_string_literal: true

class ReviewsController < StoreController
  helper Spree::BaseHelper
  include ReviewVoting

  before_action :load_product, only: [:index, :new, :create, :edit, :update, :set_positive_vote, :set_negative_vote, :flag_review]
  before_action :load_review, only: [:set_positive_vote, :set_negative_vote, :flag_review]
  before_action :initialize_review_vote, only: [:set_positive_vote, :set_negative_vote, :flag_review]
  before_action :load_store, only: [:new, :create, :edit, :update]

  def index
    @approved_reviews = Spree::Review.approved.where(product: @product)
  end

  def new
    @review = Spree::Review.new(product: @product)
    authorize! :create, @review
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def edit
    @review = Spree::Review.find(params[:id])
    if @review.product.nil?
      flash[:error] = I18n.t('spree.error_no_product')
    end
    authorize! :update, @review
  end

  # save if all ok
  def create
    review_params[:rating].sub!(/\s*[^0-9]*\z/, '') if review_params[:rating].present?

    @review = Spree::Review.new(review_params)
    @review.product = @product

    @review.store = @store
    @review.user = spree_current_user if spree_user_signed_in?
    @review.ip_address = request.remote_ip
    @review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]
    # Handle images
    params[:review][:images]&.each do |image|
      @review.images.new(attachment: image) if image.present?
    end

    authorize! :create, @review
    if @review.save
      flash.now[:notice] = I18n.t('spree.review_successfully_submitted')
      render json: { success: true, notice: flash.now[:notice] }
    else
      render partial: "reviews/form", locals: { review: @review, product: @product }, status: :unprocessable_entity
    end
  end

  def update
    review_params[:rating].sub!(/\s*[^0-9]*\z/, '') if params[:review][:rating].present?

    @review = Spree::Review.find(params[:id])

    # Handle images
    params[:review][:images]&.each do |image|
      @review.images.new(attachment: image) if image.present?
    end

    authorize! :update, @review
    if @review.update(review_params)
      flash[:notice] = I18n.t('spree.review_successfully_submitted')
      redirect_to product_path(@product)
    else
      render :edit
    end
  end

  private

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def load_review
    @review = Spree::Review.find(params[:id])
  end

  def load_store
    @store = current_store
  end

  def initialize_review_vote
    @vote = @review.review_votes.find_or_initialize_by(user_id: spree_current_user.id)
  end

  def permitted_review_attributes
    [:rating, :title, :review, :name, :show_identifier, :images]
  end

  def review_params
    params.require(:review).permit(permitted_review_attributes)
  end
end
