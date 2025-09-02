class CartItemBlueprint < Blueprinter::Base
  fields :quantity

  field :id do |item|
    item.product.id
  end

  field :name do |item|
    item.product.name
  end

  field :unit_price do |item|
    item.product.price.to_f.round(2)
  end

  field :total_price do |item|
    item.total_price.to_f.round(2)
  end
end

