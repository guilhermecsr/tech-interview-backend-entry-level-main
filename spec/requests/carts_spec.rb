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

      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end

  describe "POST /cart" do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 10.0) }

    context "when adding a new product to the cart" do
      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
      end

      subject(:request) do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
      end

      let(:expected_response) do
        {
          "id": cart.id,
          "products": [
          {
            "id": product.id,
            "name": product.name,
            "quantity": 2,
            "unit_price": product.price.to_f.round(2),
            "total_price": (2 * product.price.to_f).round(2),
          }
        ],
          "total_price": cart.total_price.to_f.round(2)
        }.to_json
      end

      it "creates a new cart item and returns the cart" do
        expect { request }.to change(CartItem, :count).by(1)
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq(JSON.parse(expected_response))
      end
    end

    context "when adding an existing product to the cart" do
      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
        create(:cart_item, cart: cart, product: product, quantity: 1)
      end

      subject(:request) do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
      end

      it "updates the quantity of the existing cart item" do
        expect { request }.not_to change(CartItem, :count)
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['products'].first['quantity']).to eq(3)
        expect(json_response['products'].first['total_price']).to eq(3 * product.price.to_f.round(2))
        expect(json_response['total_price']).to eq(cart.total_price.to_f.round(2))
      end

      it 'updates the last_interaction_at timestamp of the cart' do
        expect {
          post '/cart', params: { product_id: product.id, quantity: 1 }
        }.to change { cart.reload.last_interaction_at }
      end
    end

    context 'when cart is does not exist' do
      subject(:request) do
        post '/cart', params: { product_id: product.id, quantity: 1 }
      end

      it 'creates a new cart and a new cart item' do
        expect { request }.to change(Cart, :count).by(1).and change(CartItem, :count).by(1)
      end

      it 'returns a created status and sets the cart_id in the session' do
        request

        expect(response).to have_http_status(:created)
        expect(session[:cart_id]).to be_present
        expect(session[:cart_id]).to eq(Cart.last&.id)
      end
    end
  end

  describe "GET /cart" do
    let(:cart) { create(:cart) }
    let!(:itens) { create_list(:cart_item, 2, cart: cart, quantity: 5) }

    context "when a cart has items" do
      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
      end

      subject(:request) do
        get '/cart'
      end

      let(:expected_response) do
        {
          "id": cart.id,
          "products": [
            {
              "id": itens.first.product.id,
              "name": itens.first.product.name,
              "quantity": 5,
              "unit_price": itens.first.product.price.to_f.round(2),
              "total_price": (5 * itens.first.product.price.to_f).round(2)
            },
            {
              "id": itens.last.product.id,
              "name": itens.last.product.name,
              "quantity": 5,
              "unit_price": itens.last.product.price.to_f.round(2),
              "total_price": (5 * itens.last.product.price.to_f).round(2)
            },
          ],
          "total_price": cart.total_price.to_f.round(2)
        }.to_json
      end

      it "returns the current cart with cart_items" do
        request

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq(JSON.parse(expected_response))
      end
    end

    context 'when cart is does not have items' do
      subject(:request) do
        get '/cart'
      end

      it "returns not found" do
        request

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({"id"=>Cart.last&.id, "products"=>[], "total_price"=>0.0})
      end
    end
  end

  describe "DELETE /cart/:product_id" do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

    before do
      allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
    end

    context "when the product is in the cart" do
      subject(:request) do
        delete "/cart/#{product.id}"
      end

      it "removes the item from the cart" do
        expect { request }.to change(CartItem, :count).by(-1)
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['products']).to be_empty
      end
    end

    context "when the product is not in the cart" do
      subject(:request) do
        delete "/cart/999"
      end

      it "returns a unprocessable entity" do
        request

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it 'updates the last_interaction_at timestamp of the cart' do
      expect {
        delete "/cart/#{product.id}"
      }.to change { cart.reload.last_interaction_at }
    end
  end
end
