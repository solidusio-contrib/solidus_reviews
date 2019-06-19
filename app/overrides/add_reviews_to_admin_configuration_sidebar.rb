# frozen_string_literal: true

Spree::Backend::Config.configure do |config|
  config.menu_items.detect { |menu_item|
    menu_item.label == :settings
  }.sections << :review_settings
end

Deface::Override.new(virtual_path: "spree/admin/shared/_settings_sub_menu",
                     name: "converted_admin_configurations_menu",
                     insert_bottom: "[data-hook='admin_settings_sub_tabs']",
                     text: "<%= tab :reviews, url: spree.edit_admin_review_settings_path, match_path: /review_settings/ %>",
                     disabled: false)
