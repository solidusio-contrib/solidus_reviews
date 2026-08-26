# frozen_string_literal: true

module Spree
  module PermissionSets
    class ReviewManagement < PermissionSets::Base
      class << self
        def privilege
          :management
        end

        def category
          :product
        end
      end

      def activate!
        can :manage, Spree::Review
      end
    end
  end
end
