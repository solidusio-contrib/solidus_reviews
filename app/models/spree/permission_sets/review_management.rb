# frozen_string_literal: true

module Spree
  module PermissionSets
    class ReviewManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::Review
      end
    end
  end
end
