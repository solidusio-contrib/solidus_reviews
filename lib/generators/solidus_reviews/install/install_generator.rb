# frozen_string_literal: true

module SolidusReviews
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: false
      source_root File.expand_path('templates', __dir__)
      class_option :specs, type: :string, enum: %w[all], hide: true

      def self.exit_on_failure?
        true
      end

      def copy_initializer
        template 'initializer.rb', 'config/initializers/solidus_reviews.rb'
      end

      def add_javascripts
        append_file 'app/assets/javascripts/solidus_starter_frontend.js', "//= require spree/frontend/solidus_reviews\n"
        append_file 'vendor/assets/javascripts/spree/backend/all.js', "//= require spree/backend/solidus_reviews\n"
      end

      def add_stylesheets
        inject_into_file 'app/assets/stylesheets/solidus_starter_frontend.css', " *= require spree/frontend/solidus_reviews\n", before: %r{\*/}, verbose: true # rubocop:disable Layout/LineLength
        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', " *= require spree/backend/solidus_reviews\n", before: %r{\*/}, verbose: true # rubocop:disable Layout/LineLength
      end

      def add_reviews_and_star_overview_to_product_pages
        file_path_product_show = "app/views/products/show.html.erb"
        render_statement_product_show = "<%= render 'products/shared/reviews', product: @product %> \n    "
        file_path_product_header = "app/views/products/_product_header.html.erb"
        render_statement_product_header = "<%= render 'products/shared/star_overview', product: @product %> \n  "
        file_path_product_component = "app/components/product_card_component.html.erb"
        render_statement_product_component = "<%= render 'products/shared/product_card_star_overview', product: @product %>\n        "

        insert_into_file file_path_product_show, render_statement_product_show, before: '<div class="col-span-full pt-12">'
        insert_into_file file_path_product_header, render_statement_product_header,
          before: "<% if product.price_for_options(current_pricing_options)&.money and !product.price.nil? %>"
        insert_into_file file_path_product_component, render_statement_product_component,
          before: "<span class=\"mb-3 font-sansserif text-gray-800 dark:text-gray-50 <%= price_classes %>\""
      end

      def add_import_to_application_tailwind
        template 'star_tailwind.css', 'app/assets/stylesheets/solidus_review_stars.css'

        import_statement = "@import 'solidus_review_stars.css';\n"
        tailwind_file = "app/assets/stylesheets/application.tailwind.css"

        if File.exist?(tailwind_file)
          prepend_to_file tailwind_file, import_statement
          Rails.logger.debug "Added import statement for solidus_review_stars.css to application.tailwind.css"
        else
          Rails.logger.debug "application.tailwind.css file not found. Ensure Tailwind is installed in the host app."
        end
      end

      def add_to_tailwind_config
        tailwind_config_path = Rails.root.join('config/tailwind.config.js')

        config_content = File.read(tailwind_config_path)

        if config_content.include?("safelist:")
          say("Safelist already exists, skipping injection.")
        else
          inject_into_file tailwind_config_path, after: "require('@tailwindcss/typography')\n  ]" do
            ",\n  safelist: [\n    'stars',\n    'stars-small',\n    'fill-gray-200',\n    'fill-primary',\n    'inset-0',\n    'bg-opacity-75',\n    'bg-gray-800',\n    'float-right',\n    'sm:w-fit',\n    'w-4/5'  ]"
          end
        end
      end

      def generate_specs
        return unless options[:specs] == 'all'

        spec_path = engine.root.join('spec')

        if spec_path.directory?
          directory spec_path.to_s, 'spec'
        else
          say_status :error, "Spec directory not found: #{spec_path}", :red
        end
      end

      def add_routes
        route <<~ROUTES
          resources :products, only: [:show] do
            resources :reviews, only: [:index, :new, :create, :edit, :update] do
              member do
                post :set_positive_vote
                post :set_negative_vote
                post :flag_review
              end
            end
          end
        ROUTES
      end

      def add_migrations
        run 'bin/rails railties:install:migrations FROM=solidus_reviews'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]')) # rubocop:disable Layout/LineLength
        if run_migrations
          run 'bin/rails db:migrate'
        else
          puts 'Skipping bin/rails db:migrate, don\'t forget to run it!' # rubocop:disable Rails/Output
        end
      end

      def engine
        SolidusReviews::Engine
      end
    end
  end
end
