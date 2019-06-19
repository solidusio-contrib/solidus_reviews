# frozen_string_literal: true

module Spree::ReviewsHelper
  def star(the_class)
    content_tag(:span, " &#10030; ".html_safe, class: the_class)
  end

  def mk_stars(m)
    (1..5).collect { |n| n <= m ? star("lit") : star("unlit") }.join
  end

  def txt_stars(n, show_out_of = true)
    res = I18n.t('spree.star', count: n)
    res += " #{I18n.t('spree.out_of_5')}" if show_out_of
    res
  end

  def display_verified_purchaser?(review)
    Spree::Reviews::Config[:show_verified_purchaser] && review.user &&
    Spree::LineItem.joins(:order, :variant)
      .where.not(spree_orders: { completed_at: nil })
      .find_by(
        spree_variants: { product_id: review.product_id },
        spree_orders: { user_id: review.user_id }
      ).present?
  end
end
