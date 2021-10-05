# frozen_string_literal: true

require 'spree/core'
require 'solidus_reviews/config'

module SolidusReviews
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace Spree

    engine_name 'solidus_reviews'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    config.to_prepare do
      ::Spree::Ability.register_ability(::Spree::ReviewsAbility)
    end

    if SolidusSupport.api_available?
      paths["app/controllers"] << "lib/controllers"
    end

    initializer "spree.reviews.environment", before: :load_config_initializers do; end

    config.after_initialize do
      ::Spree::Reviews::Config.check_load_defaults_called('Spree::Reviews::Config')
    end
  end
end
