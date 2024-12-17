# frozen_string_literal: true

json.reviews(@reviews) do |review|
  json.partial!("spree/api/reviews/review", review: review)
end
json.avg_rating(@product&.avg_rating)
