# frozen_string_literal: true

json.cache! [I18n.locale, feedback_review] do
  json.(feedback_review, *feedback_review_attributes)
end
