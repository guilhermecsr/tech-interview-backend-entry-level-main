RSpec.describe Carts::Destroy do
  let(:cart) { create(:cart) }
  let(:product) { create(:product) }

  subject(:service) { described_class.new(cart: cart, product_id: product.id).call }

  describe '#call' do
    context 'when the product exists in the cart' do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product) }

      it 'returns true' do
        expect(service).to be_truthy
      end

      it 'destroys the cart item' do
        expect { service }.to change(CartItem, :count).by(-1)
      end

      it 'updates the last_interaction_at timestamp of the cart' do
        expect { service }.to change { cart.reload.last_interaction_at }
      end

      it 'does not add any errors to the cart' do
        service
        expect(cart.errors).to be_empty
      end
    end

    context 'when the product does not exist in the cart' do
      it 'returns false' do
        expect(service).to be_falsey
      end

      it 'does not change the number of cart items' do
        expect { service }.not_to change(CartItem, :count)
      end

      it 'adds an error message to the cart object' do
        service

        expect(cart.errors[:base].first).to include("Couldn't find cart item")
      end
    end
  end
end

