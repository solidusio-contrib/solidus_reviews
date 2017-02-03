require 'spec_helper'

describe Spree::ReviewsConfiguration do
  subject { Spree::ReviewsConfiguration.new }

  before do
    reset_spree_preferences
  end

  it 'should have the include_unapproved_reviews preference' do
    expect(subject).to respond_to(:preferred_include_unapproved_reviews)
    expect(subject).to respond_to(:preferred_include_unapproved_reviews=)
    expect(subject.preferred_include_unapproved_reviews).to be false
  end

  it 'should have the preview_size preference' do
    expect(subject).to respond_to(:preferred_preview_size)
    expect(subject).to respond_to(:preferred_preview_size=)
    expect(subject.preferred_preview_size).to eq(2)
  end

  it 'should have the show_email preference' do
    expect(subject).to respond_to(:preferred_show_email)
    expect(subject).to respond_to(:preferred_show_email=)
    expect(subject.preferred_show_email).to be false
  end

  it 'should have the feedback_rating preference' do
    expect(subject).to respond_to(:preferred_feedback_rating)
    expect(subject).to respond_to(:preferred_feedback_rating=)
    expect(subject.preferred_feedback_rating).to be false
  end

  it 'should have the require_login preference' do
    expect(subject).to respond_to(:preferred_require_login)
    expect(subject).to respond_to(:preferred_require_login=)
    expect(subject.preferred_require_login).to be true
  end

  it 'should have the track_locale preference', pending: 'this leaks from elsewhere, causes it to be true' do
    expect(subject).to respond_to(:preferred_track_locale)
    expect(subject).to respond_to(:preferred_track_locale=)
    expect(subject.preferred_track_locale).to be false
  end
end
