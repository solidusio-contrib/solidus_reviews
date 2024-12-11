# frozen_string_literal: true

module ReviewVoting
  extend ActiveSupport::Concern

  def set_positive_vote
    process_vote(:positive)
  end

  def set_negative_vote
    process_vote(:negative)
  end

  def flag_review
    if @vote.update_vote(Spree::ReviewVote.vote_type_value(:report), params[:report_reason], params[:comment], request.remote_ip)
      respond_to do |format|
        format.js { render 'reviews/update_review_votes' }
        format.html { redirect_to product_path(@product), notice: 'Review marked as flagged' }
        format.json {
          render json: { message: "Review marked as flagged.", flag_count: @review.flag_count, reporter: @vote.reporter_ip_address }, status: :ok
        }
      end
    else
      handle_vote_error
    end
  end

  private

  def process_vote(vote_type)
    vote_action = Spree::ReviewVote.vote_type_value(vote_type)

    if Spree::ReviewVote.user_voted?(@review, vote_action, current_user)
      process_existing_vote(vote_action, vote_type, removed: true)
    else
      process_new_vote(vote_action, vote_type)
    end
  end

  def process_existing_vote(vote_action, vote_type, removed: false)
    vote_already_exists = removed ? @vote.remove_vote(vote_action) : @vote.update_vote(vote_action)

    if vote_already_exists
      handle_vote_response(vote_type, @review.send("#{vote_type}_count"), removed: removed)
    else
      handle_vote_error
    end
  end

  def process_new_vote(vote_action, vote_type)
    process_existing_vote(vote_action, vote_type)
  end

  def handle_vote_response(vote_type, count, removed: false)
    action = removed ? "removed from #{vote_type}" : "marked as #{vote_type}"
    respond_to do |format|
      format.js { render 'reviews/update_review_votes' }
      format.html { redirect_to product_path(@product), notice: "Review marked as #{vote_type}" }
      format.json { render json: { message: "Review #{action}.", "#{vote_type}_count".to_sym => count }, status: :ok }
    end
  end

  def handle_vote_error
    respond_to do |format|
      format.html { redirect_to product_path(@product), alert: @vote.errors.full_messages.to_sentence }
      format.json { render json: { errors: @vote.errors.full_messages }, status: :unprocessable_entity }
    end
  end

  def current_user
    if respond_to?(:spree_current_user)
      spree_current_user
    elsif defined?(@current_api_user) && @current_api_user.present?
      @current_api_user
    end
  end
end
