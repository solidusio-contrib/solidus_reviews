# frozen_string_literal: true

module Spree::ReviewsHelper
  def txt_stars(n, show_out_of = true)
    res = I18n.t('spree.star', count: n)
    res += " #{I18n.t('spree.out_of_5')}" if show_out_of
    res
  end
end
