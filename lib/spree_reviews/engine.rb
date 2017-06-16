module SpreeReviews
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'solidus_reviews'

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
      Spree::Ability.register_ability(Spree::ReviewsAbility)
    end

    initializer "spree.api.versioncake" do
      VersionCake.setup do |config|
        config.resources do |r|
          r.resource %r{.*}, [], [], [1]
        end
        config.missing_version = 1
        config.extraction_strategy = :http_header
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
