# frozen_string_literal: true

require 'spec_helper'

describe Spree::ReviewsConfiguration do
  subject { described_class.new }

  before do
    subject.reset
  end

  it 'has the include_unapproved_reviews preference' do
    expect(subject).to respond_to(:preferred_include_unapproved_reviews)
    expect(subject).to respond_to(:preferred_include_unapproved_reviews=)
    expect(subject.preferred_include_unapproved_reviews).to be false
  end

  it 'has the preview_size preference' do
    expect(subject).to respond_to(:preferred_preview_size)
    expect(subject).to respond_to(:preferred_preview_size=)
    expect(subject.preferred_preview_size).to eq(3)
  end

  it 'has the show_email preference' do
    expect(subject).to respond_to(:preferred_show_email)
    expect(subject).to respond_to(:preferred_show_email=)
    expect(subject.preferred_show_email).to be false
  end

  it 'has the show_verified_purchaser preference' do
    expect(subject).to respond_to(:preferred_show_verified_purchaser)
    expect(subject).to respond_to(:preferred_show_verified_purchaser=)
    expect(subject.preferred_show_verified_purchaser).to be false
  end

  it 'has the feedback_rating preference' do
    expect(subject).to respond_to(:preferred_feedback_rating)
    expect(subject).to respond_to(:preferred_feedback_rating=)
    expect(subject.preferred_feedback_rating).to be false
  end

  it 'has the require_login preference' do
    expect(subject).to respond_to(:preferred_require_login)
    expect(subject).to respond_to(:preferred_require_login=)
    expect(subject.preferred_require_login).to be true
  end

  it 'has the track_locale preference' do
    expect(subject).to respond_to(:preferred_track_locale)
    expect(subject).to respond_to(:preferred_track_locale=)
    expect(subject.preferred_track_locale).to be false
  end
end
