xml.instruct! :xml, version: "1.0", encoding: 'UTF-8'

xml.feed(
  'xmlns:vc' => "http://www.w3.org/2007/XMLSchema-versioning",
  'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
  'xsi:noNamespaceSchemaLocation' => "http://www.google.com/shopping/reviews/schema/product/2.2/product_reviews.xsd",
) do
  xml.version '2.2'

  xml.publisher do
    xml.name current_store.name
    xml.favicon "#{current_store.url}/favicon.ico"
  end

  xml.reviews do
    @approved_reviews.each do |review|
      xml.review do
        xml.review_id review.id
        xml.reviewer do
          xml.name(review.name, is_anonymous: !review.user)
          if review.user
            xml.reviewer_id review.user.id
          end
        end
        xml.review_timestamp review.created_at.xmlschema
        if review.title.present?
          xml.title review.title
        end
        xml.content review.review
        xml.review_url spree.product_url(review.product), type: 'group'
        xml.ratings do
          xml.overall review.rating, min: 1, max: 5
        end
        xml.products do
          xml.product do
            xml.product_ids do
              xml.skus do
                review.product.variants_including_master.each do |variant|
                  xml.sku variant.sku
                end
              end
            end
            xml.product_name review.product.name
            xml.product_url spree.product_url(review.product)
          end
        end
      end
    end
  end
end
