# frozen_string_literal: true

require 'solidus_reviews_helper'

RSpec.describe Spree::ReviewsHelper do
  context 'txt_stars' do
    specify do
      expect(txt_stars(2, true)).to eq '2 out of 5'
    end

    specify do
      expect(txt_stars(3, false)).to be_a String
      expect(txt_stars(3, false)).to eq('3')
    end
  end
end
