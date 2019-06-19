# frozen_string_literal: true

Spree.user_class.has_many :reviews, class_name: 'Spree::Review'
