require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "POST /add_items" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
      end

      it 'updates the quantity of the existing item in the cart' do
        expect {
          post '/cart/add_item', params: { product_id: product.id, quantity: 2 }, as: :json
        }.to change { cart_item.reload.quantity }.from(1).to(3)
      end
    end
  end

  let!(:cart) { create(:cart) }
  let!(:product) { create(:product, price: 10.0) }

  describe "POST /cart" do
    context "when adding a new product to the cart" do
      it "creates a new cart item and returns the cart" do
        expect {
          post '/cart', params: { product_id: product.id, quantity: 2 }
        }.to change(CartItem, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['products'].first['quantity']).to eq(2)
        expect(json_response['total_price']).to eq(20.0)
      end
    end

    context "when adding an existing product to the cart" do
      before do
        create(:cart_item, cart: cart, product: product, quantity: 1)
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
      end

      it "updates the quantity of the existing cart item" do
        expect {
          post '/cart', params: { product_id: product.id, quantity: 3 }
        }.not_to change(CartItem, :count)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['products'].first['quantity']).to eq(4) # 1 (existente) + 3 (adicionado)
        expect(json_response['total_price']).to eq(40.0)
      end
    end

    it 'updates the last_interaction_at timestamp of the cart' do
      allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })

      expect {
        post '/cart', params: { product_id: product.id, quantity: 1 }
      }.to change { cart.reload.last_interaction_at }
    end
  end

  describe "GET /cart" do
    context "when a cart exists" do
      before do
        create(:cart_item, cart: cart, product: product, quantity: 5)
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
      end

      it "returns the current cart" do
        get '/cart'

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(cart.id)
        expect(json_response['products'].first['id']).to eq(product.id)
        expect(json_response['products'].first['quantity']).to eq(5)
      end
    end
  end

  describe "DELETE /cart/:product_id" do
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

    before do
      allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
    end

    context "when the product is in the cart" do
      it "removes the item from the cart" do
        expect {
          delete "/cart/#{product.id}"
        }.to change(CartItem, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['products']).to be_empty
      end
    end

    context "when the product is not in the cart" do
      it "returns a not found status" do
        delete "/cart/999"

        expect(response).to have_http_status(:not_found)
      end
    end

    it 'updates the last_interaction_at timestamp of the cart' do
      expect {
        delete "/cart/#{product.id}"
      }.to change { cart.reload.last_interaction_at }
    end
  end
end
