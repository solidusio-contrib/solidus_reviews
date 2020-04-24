# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '/reviews_feed' do
  describe 'GET /.xml' do
    subject { -> { get '/reviews_feed.xml' } }

    let!(:review) { create(:review, :approved) }
    let!(:anonymous_review) { create(:review, :approved, :anonymous) }

    before do
      Spree::Core::Engine.routes.default_url_options = { host: 'www.example.com' }
    end

    context 'when :enable_reviews_feed is explicitly enabled' do
      before do
        stub_spree_preferences(Spree::Reviews::Config, enable_reviews_feed: true)
        Rails.application.reload_routes!
      end

      it 'responds with 200 OK' do
        subject.call

        expect(response.status).to eq(200)
      end

      it 'matches the expected snapshot' do
        subject.call

        expect(response.body).to eq(<<~XML)
          <?xml version="1.0" encoding="UTF-8"?>
          <feed xmlns:vc="http://www.w3.org/2007/XMLSchema-versioning" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.google.com/shopping/reviews/schema/product/2.2/product_reviews.xsd">
            <version>2.2</version>
            <publisher>
              <name/>
              <favicon>/favicon.ico</favicon>
            </publisher>
            <reviews>
              <review>
                <review_id>#{anonymous_review.id}</review_id>
                <reviewer>
                  <name is_anonymous="true">#{anonymous_review.name}</name>
                </reviewer>
                <review_timestamp>#{anonymous_review.created_at.xmlschema}</review_timestamp>
                <title>#{anonymous_review.title}</title>
                <content>#{anonymous_review.review}</content>
                <review_url type="group">#{spree.product_url(anonymous_review.product)}</review_url>
                <ratings>
                  <overall min="1" max="5">#{anonymous_review.rating}</overall>
                </ratings>
                <products>
                  <product>
                    <product_ids>
                      <skus>
                        <sku>#{anonymous_review.product.sku}</sku>
                      </skus>
                    </product_ids>
                    <product_name>#{anonymous_review.product.name}</product_name>
                    <product_url>#{spree.product_url(anonymous_review.product)}</product_url>
                  </product>
                </products>
              </review>
              <review>
                <review_id>#{review.id}</review_id>
                <reviewer>
                  <name is_anonymous="false">#{review.name}</name>
                  <reviewer_id>#{review.user.id}</reviewer_id>
                </reviewer>
                <review_timestamp>#{review.created_at.xmlschema}</review_timestamp>
                <title>#{review.title}</title>
                <content>#{review.review}</content>
                <review_url type="group">#{spree.product_url(review.product)}</review_url>
                <ratings>
                  <overall min="1" max="5">#{review.rating}</overall>
                </ratings>
                <products>
                  <product>
                    <product_ids>
                      <skus>
                        <sku>#{review.product.sku}</sku>
                      </skus>
                    </product_ids>
                    <product_name>#{review.product.name}</product_name>
                    <product_url>#{spree.product_url(review.product)}</product_url>
                  </product>
                </products>
              </review>
            </reviews>
          </feed>
        XML
      end
    end

    context 'when :enable_reviews_feed is not explicitly enabled' do
      before { Rails.application.reload_routes! }

      it 'does not find the route' do
        expect(subject).to raise_error(ActionController::RoutingError)
      end
    end
  end
end
