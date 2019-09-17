# frozen_string_literal: true

module SpreeReviews
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'solidus_reviews'

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
      Spree::Ability.register_ability(Spree::ReviewsAbility)
    end

    if SolidusSupport.api_available?
      paths["app/controllers"] << "lib/controllers"
    end

    config.to_prepare &method(:activate).to_proc
  end
end
