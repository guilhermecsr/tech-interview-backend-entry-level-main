class CartsController < ApplicationController
  include CurrentCart

  before_action :set_cart, only: [:create, :show, :destroy, :add_item]

  # GET /cart
  def show
    render json: format_cart(@cart)
  end

  def create
    service = Carts::Create.new(
      cart: @cart,
      product_id: cart_params[:product_id],
      quantity: cart_params[:quantity]
    )

    if service.call
      render json: format_cart(@cart), status: :created
    else
      render json: { errors: @cart.errors.messages }, status: :unprocessable_entity
    end
  end

  # POST /cart/add_item
  def add_item
    service = Carts::AddItem.new(
      cart: @cart,
      product_id: cart_params[:product_id],
      quantity: cart_params[:quantity]
    )

    if service.call
      render json: format_cart(@cart), status: :created
    else
      render json: { errors: @cart.errors.messages }, status: :unprocessable_entity
    end
  end

  # DELETE /cart/:product_id
  def destroy
    service = Carts::Destroy.new(
      cart: @cart,
      product_id: params[:product_id]
    )

    if service.call
      render json: format_cart(@cart), status: :ok
    else
      render json: { errors: @cart.errors.messages }, status: :unprocessable_entity
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
          unit_price: item.product.price.to_f.round(2),
          total_price: item.total_price.to_f.round(2)
        }
      end,
      total_price: cart.total_price.to_f.round(2)
    }
  end
end
