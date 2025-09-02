class CartBlueprint < Blueprinter::Base
  identifier :id

  field :total_price do |cart|
    cart.total_price.to_f.round(2)
  end

  association :cart_items, name: :products, blueprint: CartItemBlueprint
end

