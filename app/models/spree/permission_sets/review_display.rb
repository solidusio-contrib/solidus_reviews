# frozen_string_literal: true

module Spree
  module PermissionSets
    class ReviewDisplay < PermissionSets::Base
      class << self
        def privilege
          :display
        end

        def category
          :review
        end
      end

      def activate!
        can [:display, :admin], Spree::Review
      end
    end
  end
end
