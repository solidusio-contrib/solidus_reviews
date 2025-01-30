# frozen_string_literal: true

json.cache! [I18n.locale, review] do
  json.call(review, *review_attributes)
  json.images(review.images) do |image|
    json.partial!("spree/api/images/image", image: image)
  end
end
