# frozen_string_literal: true

module Spree
  class ReviewVote < ApplicationRecord
    POSITIVE = 'Positive'
    NEGATIVE = 'Negative'
    REPORT = 'Report'

    VOTE_TYPES = {
      positive: POSITIVE,
      negative: NEGATIVE,
      report: REPORT
    }.freeze

    belongs_to :review
    belongs_to :user

    validates :vote_type, allow_blank: true, inclusion: { in: VOTE_TYPES.values }
    validate :validate_vote_type_change

    after_commit :increment_vote_count, on: :create
    after_commit :update_vote_count, on: :update

    def update_vote(vote_type, report_reason = nil, comment = nil, reporter_ip_address = nil)
      ActiveRecord::Base.transaction do
        self.vote_type = vote_type
        self.report_reason = report_reason.presence
        self.comment = comment.presence
        self.reporter_ip_address = reporter_ip_address.presence

        save!
      end
    end

    def self.user_voted?(review, vote_type, user)
      exists?(review_id: review.id, vote_type: vote_type, user_id: user&.id)
    end

    def remove_vote(vote_type)
      ActiveRecord::Base.transaction do
        vote = self.class.find_by(review_id: review.id, user_id: user.id, vote_type: vote_type)
        if vote
          vote.destroy
          update_vote_counter(vote_type, decrement: true)
        end
      end
    end

    def self.vote_type_value(key)
      VOTE_TYPES[key]
    end

    def validate_vote_type_change
      return unless vote_type == vote_type_was

      errors.add(:vote_type, "has already been set to this value")
    end

    def increment_vote_count
      update_vote_counter(vote_type, increment: true)
    end

    def update_vote_count
      return unless saved_change_to_vote_type?

      adjust_vote_count(
        previous_vote: vote_type_before_last_save,
        current_vote: vote_type
      )
    end

    def adjust_vote_count(previous_vote:, current_vote:)
      update_vote_counter(previous_vote, decrement: true) if previous_vote
      update_vote_counter(current_vote, increment: true) if current_vote
    end

    def update_vote_counter(vote, increment: false, decrement: false)
      counter_map = {
        POSITIVE => :positive_count,
        NEGATIVE => :negative_count,
        REPORT => :flag_count
      }

      counter = counter_map[vote]

      return unless counter

      review.increment!(counter) if increment
      review.decrement!(counter) if decrement
    end
  end
end
