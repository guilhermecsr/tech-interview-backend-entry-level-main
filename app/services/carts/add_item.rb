module Carts
  class AddItem
    def initialize(cart:, product_id:, quantity:)
      @cart = cart
      @product_id = product_id
      @quantity = quantity.to_i
    end

    def call
      Cart.transaction do
        cart_item.increment!(:quantity, @quantity.to_i)
        @cart.update(last_interaction_at: Time.current, total_price: @cart.current_total_price) if cart_item.save!
      end

      true
    rescue ActiveRecord::Rollback, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
      false
    end

    private

    def cart_item
      @cart_item ||= @cart.cart_items.find_by!(product: product)
    end

    def product
      @product ||= Product.find_by!(id: @product_id)
    end
  end
end

