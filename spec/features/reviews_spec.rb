# frozen_string_literal: true

require 'spec_helper'
require 'spree/testing_support/authorization_helpers'

describe 'Reviews', js: true do
  let!(:someone) { create(:user, email: 'ryan@spree.com') }
  let!(:review) { create(:review, :approved, user: someone) }
  let!(:unapproved_review) { create(:review, product: review.product) }

  before do
    stub_spree_preferences(Spree::Reviews::Config, include_unapproved_reviews: false)
  end

  context 'product with no review' do
    let!(:product_no_reviews) { create(:product) }

    it 'informs that no reviews has been written yet' do
      visit spree.product_path(product_no_reviews)
      expect(page).to have_text I18n.t('spree.no_reviews_available')
    end

    # Regression test for #103
    context "shows correct number of previews" do
      before do
        FactoryBot.create_list :review, 3, product: product_no_reviews, approved: true
        stub_spree_preferences(Spree::Reviews::Config, preview_size: 2)
      end

      it "displayed reviews are limited by the set preview size" do
        visit spree.product_path(product_no_reviews)
        expect(page.all(".review").count).to be(2)
      end
    end
  end

  context 'when anonymous user' do
    before do
      stub_spree_preferences(Spree::Reviews::Config, require_login: true)
    end

    context 'visit product with review' do
      before do
        visit spree.product_path(review.product)
      end

      it 'sees review title' do
        expect(page).to have_text review.title
      end

      it 'can not create review' do
        expect(page).not_to have_text I18n.t('spree.write_your_own_review')
      end
    end
  end

  context 'when logged in user' do
    let!(:user) { create(:user) }

    before do
      sign_in_as! user
    end

    context 'visit product with review' do
      before do
        visit spree.product_path(review.product)
      end

      it 'can see review title' do
        expect(page).to have_text review.title
      end

      context 'with unapproved content allowed' do
        before do
          stub_spree_preferences(Spree::Reviews::Config, include_unapproved_reviews: true)
          stub_spree_preferences(Spree::Reviews::Config, display_unapproved_reviews: true)
          visit spree.product_path(review.product)
        end

        it 'can see unapproved content when allowed' do
          expect(unapproved_review.approved?).to eq(false)
          expect(page).to have_text unapproved_review.title
        end
      end

      it 'can see create new review button' do
        expect(page).to have_text I18n.t('spree.write_your_own_review')
      end

      it 'can create new review' do
        click_on I18n.t('spree.write_your_own_review')

        expect(page).to have_text I18n.t('spree.leave_us_a_review_for', name: review.product.name)
        expect(page).not_to have_text 'Show Identifier'

        within '#new_review' do
          click_star(3)

          fill_in 'review_name', with: user.email
          fill_in 'review_title', with: 'Great product!'
          fill_in 'review_review', with: 'Some big review text..'
          attach_file 'review_images', 'spec/fixtures/thinking-cat.jpg'
          click_on 'Submit your review'
        end

        expect(page.find('.flash.notice', text: I18n.t('spree.review_successfully_submitted'))).to be_truthy
        expect(page).not_to have_text 'Some big review text..'
      end
    end
  end

  context 'visit product with review where show_identifier is false' do
    let!(:user) { create(:user) }
    let!(:review) { create(:review, :approved, :hide_identifier, review: 'review text', user: user) }

    before do
      visit spree.product_path(review.product)
    end

    it 'show anonymous review' do
      expect(page).to have_text I18n.t('spree.anonymous')
      expect(page).to have_text 'review text'
    end
  end

  private

  def sign_in_as!(user)
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationController).to receive_messages current_user: user
    allow_any_instance_of(ApplicationController).to receive_messages spree_current_user: user
    allow_any_instance_of(ApplicationController).to receive_messages spree_user_signed_in?: true
    # rubocop:enable RSpec/AnyInstance
  end

  def click_star(num)
    page.all(:xpath, "//a[@title='#{num} stars']")[0].click
  end
end
