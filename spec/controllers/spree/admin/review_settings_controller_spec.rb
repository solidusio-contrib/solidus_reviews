# frozen_string_literal: true

require 'solidus_reviews_helper'

RSpec.describe Spree::Admin::ReviewSettingsController do
  routes { Spree::Core::Engine.routes }
  stub_authorization!

  before do
    user = create(:admin_user)
    allow(controller).to receive(:spree_current_user).and_return(user)
  end

  describe '#update' do
    it 'redirects to edit-review-settings page' do
      put :update, params: { preferences: { preview_size: 4 } }
      expect(response).to redirect_to spree.edit_admin_review_settings_path
    end

    context 'with parameters:
            preview_size: 4,
            show_email: false,
            require_login: true,
            track_locale: true' do
      it 'sets preferred_preview_size to 4' do
        put :update, params: { preferences: { preview_size: 4 } }
        expect(Spree::Reviews::Config.preferred_preview_size).to eq 4
      end

      it 'sets preferred_show_email to false' do
        put :update, params: { preferences: { show_email: false } }
        expect(Spree::Reviews::Config.preferred_show_email).to be false
      end

      it 'sets preferred_require_login to true' do
        put :update, params: { preferences: { require_login: true } }
        expect(Spree::Reviews::Config.preferred_require_login).to be true
      end

      it 'sets preferred_track_locale to true' do
        put :update, params: { preferences: { track_locale: true } }
        expect(Spree::Reviews::Config.preferred_track_locale).to be true
      end
    end
  end

  describe '#edit' do
    it 'renders the edit template' do
      get :edit
      expect(response).to render_template(:edit)
    end
  end
end
