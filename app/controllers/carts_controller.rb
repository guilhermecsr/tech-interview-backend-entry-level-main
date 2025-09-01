class CartsController < ApplicationController
  include CurrentCart

  before_action :set_cart, only: [:show, :create, :destroy, :add_item]

  # GET /cart
  def show
    render json: format_cart(@cart)
  end

  # POST /cart
  def create
    product = Product.find(cart_params[:product_id])
    quantity = cart_params[:quantity].to_i

    @cart_item = @cart.cart_items.find_by(product_id: product.id)

    if @cart_item
      @cart_item.quantity += quantity
    else
      @cart_item = @cart.cart_items.build(product: product, quantity: quantity)
    end

    if @cart_item.save
      @cart.touch(:last_interaction_at)
      render json: format_cart(@cart), status: :created
    else
      render json: @cart_item.errors, status: :unprocessable_entity
    end
  end

  # POST /cart/add_item
  def add_item
    create
  end

  # DELETE /cart/:product_id
  def destroy
    cart_item = @cart.cart_items.find_by(product_id: params[:product_id])

    if cart_item
      cart_item.destroy
      @cart.touch(:last_interaction_at)
      render json: format_cart(@cart)
    else
      render json: { error: 'Product not found in cart' }, status: :not_found
    end
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def format_cart(cart)
    {
      id: cart.id,
      products: cart.cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price,
          total_price: item.total_price.to_f
        }
      end,
      total_price: cart.total_price.to_f
    }
  end
end
