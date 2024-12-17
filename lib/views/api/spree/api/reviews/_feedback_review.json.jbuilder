# frozen_string_literal: true

json.cache! [I18n.locale, feedback_review] do
  json.call(feedback_review, *feedback_review_attributes)
end
