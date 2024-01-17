# frozen_string_literal: true

Spree::Backend::Config.configure do |config|
  config.menu_items = config.menu_items.map do |item|
    if item.label.to_sym == :settings
      # The API of the MenuItem class changes in Solidus 4.2.0
      if item.respond_to?(:children)
        item.children << Spree::BackendConfiguration::MenuItem.new(
          label: :reviews,
          condition: -> { can?(:admin, Spree::ReviewsConfiguration) },
          url: -> { Spree::Core::Engine.routes.url_helpers.edit_admin_review_settings_path },
          match_path: /review_settings/
        )
      else
        item.sections << :reviews
      end
    elsif item.label.to_sym == :products
      if item.respond_to?(:children)
        item.children << Spree::BackendConfiguration::MenuItem.new(
          label: :reviews,
          condition: -> { can?(:admin, Spree::Review) },
          url: -> { Spree::Core::Engine.routes.url_helpers.admin_reviews_path },
          match_path: /reviews/
        )
      else
        item.sections << :reviews
      end
    end
    item
  end
end
