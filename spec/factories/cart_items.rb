FactoryBot.define do
  factory :cart_item do
    association :cart
    association :product
    quantity { rand(1..5) }
  end
end
