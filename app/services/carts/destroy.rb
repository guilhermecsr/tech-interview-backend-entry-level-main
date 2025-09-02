module Carts
  class Destroy
    def initialize(cart:, product_id:)
      @cart = cart
      @product_id = product_id
    end

    def call
      cart_item = @cart.cart_items.find_by!(product_id: @product_id)
      cart_item.destroy!
      @cart.touch(:last_interaction_at)

      true
    rescue ActiveRecord::RecordNotFound
      @cart.errors.add(:base, "Couldn't find cart item")
      false
    end
  end
end

