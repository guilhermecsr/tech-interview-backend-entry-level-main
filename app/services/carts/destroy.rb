module Carts
  class Destroy
    def initialize(cart:, product_id:)
      @cart = cart
      @product_id = product_id
    end

    def call
      Cart.transaction do
        cart_item = @cart.cart_items.find_by!(product_id: @product_id)
        cart_item.destroy!
        @cart.update(last_interaction_at: Time.current, total_price: @cart.current_total_price) if cart_item.destroyed?
      end

      true
    rescue ActiveRecord::RecordNotFound
      @cart.errors.add(:base, "Couldn't find cart item")
      false
    end
  end
end

