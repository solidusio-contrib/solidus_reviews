# frozen_string_literal: true

class Spree::ReviewsController < Spree::StoreController
  helper Spree::BaseHelper
  before_action :load_product, only: [:index, :new, :create, :edit, :update]

  def index
    @approved_reviews = Spree::Review.approved.where(product: @product)
  end

  def new
    @review = Spree::Review.new(product: @product)
    authorize! :create, @review
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
    @review.user = spree_current_user if spree_user_signed_in?
    @review.ip_address = request.remote_ip
    @review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]
    # Handle images
    params[:review][:images]&.each do |image|
      @review.images.new(attachment: image)
    end

    authorize! :create, @review

    respond_to do |format|
      if @review.save
        format.html {
          redirect_to spree.product_path(@product), notice: I18n.t('spree.review_successfully_submitted')
        }
        format.js
        format.json { render json: @review, status: :created, location: @review }
      else
        format.html { render action: "new" }
        format.js
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    review_params[:rating].sub!(/\s*[^0-9]*\z/, '') if params[:review][:rating].present?

    @review = Spree::Review.find(params[:id])

    # Handle images
    params[:review][:images]&.each do |image|
      @review.images.new(attachment: image)
    end

    authorize! :update, @review
    if @review.update(review_params)
      flash[:notice] = I18n.t('spree.review_successfully_submitted')
      redirect_to spree.product_path(@product)
    else
      render :edit
    end
  end

  private

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def permitted_review_attributes
    [:rating, :title, :review, :name, :show_identifier, :images]
  end

  def review_params
    params.require(:review).permit(permitted_review_attributes)
  end
end
