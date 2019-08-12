# frozen_string_literal: true

require 'spec_helper'

describe Spree::Product do
  it { is_expected.to respond_to(:avg_rating) }
  it { is_expected.to respond_to(:reviews) }
  it { is_expected.to respond_to(:stars) }

  context '#stars' do
    let(:product) { build(:product) }

    it 'rounds' do
      allow(product).to receive(:avg_rating).and_return(3.7)
      expect(product.stars).to eq(4)

      allow(product).to receive(:avg_rating).and_return(2.3)
      expect(product.stars).to eq(2)
    end

    it 'handles a nil value' do
      allow(product).to receive(:avg_rating).and_return(nil)

      expect {
        expect(product.stars).to eq(0)
      }.not_to raise_error
    end
  end

  context '#recalculate_rating' do
    let!(:product) { create(:product) }

    context 'when there are approved reviews' do
      let!(:approved_review_1) { create(:review, product: product, approved: true, rating: 4) }
      let!(:approved_review_2) { create(:review, product: product, approved: true, rating: 5) }
      let!(:unapproved_review_1) { create(:review, product: product, approved: false, rating: 4) }

      context "including unapproved reviews" do
        before(:all) do
          Spree::Reviews::Config[:include_unapproved_reviews] = true
        end
        after(:all) do
          Spree::Reviews::Config[:include_unapproved_reviews] = false
        end

        it "updates the product average rating and ignores unapproved reviews" do
          product.avg_rating = 0
          product.reviews_count = 0
          product.save!

          product.recalculate_rating
          expect(product.avg_rating).to eq(4.3)
          expect(product.reviews_count).to eq(3)
        end
      end

      context "only approved reviews" do
        it "updates the product average rating and ignores unapproved reviews" do
          product.avg_rating = 0
          product.reviews_count = 0
          product.save!

          product.recalculate_rating
          expect(product.avg_rating).to eq(4.5)
          expect(product.reviews_count).to eq(2)
        end
      end
    end

    context "without unapproved reviews" do
      let!(:unapproved_review_1) { create(:review, product: product, approved: false, rating: 4) }

      it "updates the product average rating and ignores unapproved reviews" do
        product.avg_rating = 3
        product.reviews_count = 20
        product.save!

        product.recalculate_rating
        expect(product.avg_rating).to eq(0)
        expect(product.reviews_count).to eq(0)
      end
    end
  end
end
