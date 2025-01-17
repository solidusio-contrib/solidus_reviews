# frozen_string_literal: true

module Spree
  module PermissionSets
    class ReviewManagement < PermissionSets::Base
      class << self
        def privilege
          :manage
        end

        def category
          :review
        end
      end

      def activate!
        can :manage, Spree::Review
      end
    end
  end
end
