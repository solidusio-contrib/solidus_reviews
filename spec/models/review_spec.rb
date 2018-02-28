require 'spec_helper'

describe Spree::Review do

  context 'validations' do
    it 'validates by default' do
      expect(build(:review)).to be_valid
    end

    it 'validates with a nil user' do
      expect(build(:review, user: nil)).to be_valid
    end

    it 'does not validate with a nil review' do
      expect(build(:review, review: nil)).to_not be_valid
    end

    context 'rating' do
      it 'does not validate when no rating is specified' do
        expect(build(:review, rating: nil)).to_not be_valid
      end

      it 'does not validate when the rating is not a number' do
        expect(build(:review, rating: 'not_a_number')).to_not be_valid
      end

      it 'does not validate when the rating is a float' do
        expect(build(:review, rating: 2.718)).to_not be_valid
      end

      it 'does not validate when the rating is less than 1' do
        expect(build(:review, rating: 0)).to_not be_valid
        expect(build(:review, rating: -5)).to_not be_valid
      end

      it 'does not validate when the rating is greater than 5' do
        expect(build(:review, rating: 6)).to_not be_valid
        expect(build(:review, rating: 8)).to_not be_valid
      end

      (1..5).each do |i|
        it "validates when the rating is #{i}" do
          expect(build(:review, rating: i)).to be_valid
        end
      end
    end

    context 'review body' do
      it 'should not be valid without a body' do
        expect(build(:review, review: nil)).to_not be_valid
      end
    end
  end

  context 'scopes' do
    context 'most_recent_first' do
      let!(:review_1) { create(:review, created_at: 10.days.ago) }
      let!(:review_2) { create(:review, created_at: 2.days.ago) }
      let!(:review_3) { create(:review, created_at: 5.days.ago) }

      it 'properly runs most_recent_first queries' do
        expect(Spree::Review.most_recent_first.to_a).to eq([review_2, review_3, review_1])
      end

      it 'defaults to most_recent_first queries' do
        expect(Spree::Review.all.to_a).to eq([review_2, review_3, review_1])
      end
    end

    context 'oldest_first' do
      let!(:review_1) { create(:review, created_at: 10.days.ago) }
      let!(:review_2) { create(:review, created_at: 2.days.ago) }
      let!(:review_3) { create(:review, created_at: 5.days.ago) }
      let!(:review_4) { create(:review, created_at: 1.days.ago) }

      before do
        reset_spree_preferences
        Spree::Reviews::Config.preference_store = Spree::Reviews::Config.default_preferences
      end

      it 'properly runs oldest_first queries' do
        expect(Spree::Review.oldest_first.to_a).to eq([review_1, review_3, review_2, review_4])
      end

      it 'uses oldest_first for preview' do
        expect(Spree::Review.preview.to_a).to eq([review_1, review_3, review_2])
      end
    end

    context 'localized' do
      let!(:en_review_1) { create(:review, locale: 'en', created_at: 10.days.ago) }
      let!(:en_review_2) { create(:review, locale: 'en', created_at: 2.days.ago) }
      let!(:en_review_3) { create(:review, locale: 'en', created_at: 5.days.ago) }

      let!(:es_review_1) { create(:review, locale: 'es', created_at: 10.days.ago) }
      let!(:fr_review_1) { create(:review, locale: 'fr', created_at: 10.days.ago) }

      it 'properly runs localized queries' do
        expect(Spree::Review.localized('en').to_a).to eq([en_review_2, en_review_3, en_review_1])
        expect(Spree::Review.localized('es').to_a).to eq([es_review_1])
        expect(Spree::Review.localized('fr').to_a).to eq([fr_review_1])
      end
    end

    context 'approved / not_approved / default_approval_filter' do
      let!(:approved_review_1) { create(:review, approved: true, created_at: 10.days.ago) }
      let!(:approved_review_2) { create(:review, approved: true, created_at: 2.days.ago) }
      let!(:approved_review_3) { create(:review, approved: true, created_at: 5.days.ago) }

      let!(:unapproved_review_1) { create(:review, approved: false, created_at: 7.days.ago) }
      let!(:unapproved_review_2) { create(:review, approved: false, created_at: 1.days.ago) }

      it 'properly runs approved and unapproved queries' do
        expect(Spree::Review.approved.to_a).to eq([approved_review_2, approved_review_3, approved_review_1])
        expect(Spree::Review.not_approved.to_a).to eq([unapproved_review_2, unapproved_review_1])

        Spree::Reviews::Config[:include_unapproved_reviews] = true
        expect(Spree::Review.default_approval_filter.to_a).to eq([unapproved_review_2,
                                                              approved_review_2,
                                                              approved_review_3,
                                                              unapproved_review_1,
                                                              approved_review_1])

        Spree::Reviews::Config[:include_unapproved_reviews] = false
        expect(Spree::Review.default_approval_filter.to_a).to eq([approved_review_2, approved_review_3, approved_review_1])
      end
    end
  end

  context "#recalculate_product_rating" do
    let(:product) { create(:product) }
    let!(:review) { create(:review, product: product) }

    before { product.reviews << review }

    it "if approved" do
      expect(review).to receive(:recalculate_product_rating)
      review.approved = true
      review.save!
    end

    it "if not approved" do
      expect(review).to_not receive(:recalculate_product_rating)
      review.save!
    end

    it "updates the product average rating" do
      expect(review.product).to receive(:recalculate_rating)
      review.approved = true
      review.save!
    end
  end

  context "#feedback_stars" do
    let!(:review) { create(:review) }
    before do
      3.times do |i|
        f = Spree::FeedbackReview.new
        f.review = review
        f.rating = (i+1)
        f.save
      end
    end

    it "should return the average rating from feedback reviews" do
      expect(review.feedback_stars).to eq 2
    end
  end

  context "#email" do
    it "returns email from user when there is a user" do
      user = build(:user, email: "john@smith.com")
      review = build(:review, user: user)
      expect(review.email).to eq("john@smith.com")
    end

    it "returns email from review when there is no user" do
      review = build(:review, email: "john@smith.com")
      expect(review.email).to eq("john@smith.com")
    end
  end
end
