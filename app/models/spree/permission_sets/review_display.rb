# frozen_string_literal: true

module Spree
  module PermissionSets
    class ReviewDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin], Spree::Review
      end
    end
  end
end
