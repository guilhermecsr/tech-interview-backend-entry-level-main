class CartsController < ApplicationController
  include CurrentCart

  before_action :set_cart, only: [:create, :show, :destroy, :add_item]

  # GET /cart
  def show
    render json: CartBlueprint.render(cart_with_associations)
  end

  def create
    service = Carts::Create.new(
      cart: @cart,
      product_id: cart_params[:product_id],
      quantity: cart_params[:quantity]
    )

    if service.call
      render json: CartBlueprint.render(cart_with_associations), status: :created
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
      render json: CartBlueprint.render(cart_with_associations), status: :created
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
      render json: CartBlueprint.render(cart_with_associations), status: :ok
    else
      render json: { errors: @cart.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def cart_with_associations
    @cart.class.includes(cart_items: :product).find(@cart.id)
  end
end

