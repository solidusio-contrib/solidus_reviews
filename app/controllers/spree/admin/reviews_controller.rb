# frozen_string_literal: true

class Spree::Admin::ReviewsController < Spree::Admin::ResourceController
  helper Spree::ReviewsHelper

  def index
    @reviews = collection
  end

  def approve
    review = Spree::Review.find(params[:id])

    if review.update_attribute(:approved, true)
      flash[:success] = I18n.t('spree.info_approve_review')
    else
      flash[:error] = I18n.t('spree.error_approve_review')
    end

    redirect_to admin_reviews_path
  end

  def edit
    if @review.product.nil?
      flash[:error] = I18n.t('spree.error_no_product')
      redirect_to admin_reviews_path
    end
  end

  private

  def collection
    params[:q] ||= {}

    @search = Spree::Review.ransack(params[:q])
    @collection = @search.result.includes([:product, :user, :feedback_reviews]).page(params[:page]).per(params[:per_page])
  end
end
