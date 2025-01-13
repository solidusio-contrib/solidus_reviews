# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusReviews
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    include Flickwerk

    Flickwerk.aliases["Spree.user_class"] = Spree.user_class_name

    if SolidusSupport.api_available?
      config.autoload_paths += root.join("lib", "patches", "api").glob("*")
    end

    initializer "solidus_reviews_api_patches", before: "flickwerk.add_patch_paths" do
      patch_path = root.join("lib", "patches", "api")
      Flickwerk.patch_paths += [patch_path]
    end

    if SolidusSupport.frontend_available?
      config.autoload_paths += root.join("lib", "patches", "frontend").glob("*")
    end

    initializer "solidus_reviews_frontend_patches", before: "flickwerk.add_patch_paths" do
      patch_path = root.join("lib", "patches", "frontend")
      Flickwerk.patch_paths += [patch_path]
    end

    isolate_namespace ::Spree

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
  end
end
