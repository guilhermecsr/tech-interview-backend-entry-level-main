RSpec.describe Carts::AddItem do
  let(:cart) { create(:cart) }
  let(:product) { create(:product) }
  let(:cart_item) { create(:cart_item, product: product, quantity: 1) }
  let(:quantity) { 2 }

  subject(:service) { described_class.new(cart: cart, product_id: product.id, quantity: quantity).call }

  describe '#call' do
    context 'when the product is NOT already in the cart' do
      it 'returns false' do
        expect(service).to be_falsey
      end

      it 'does not create a new cart item' do
        expect { service }.not_to change(CartItem, :count)
      end
    end

    context 'when adding an existing product to the cart' do
      let!(:existing_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }
      let(:quantity) { 3 }

      it 'returns true' do
        expect(service).to be_truthy
      end

      it 'does not create a new cart item' do
        expect { service }.not_to change(CartItem, :count)
      end

      it 'updates the quantity of the existing item' do
        expect { service }.to change { existing_item.reload.quantity }.from(1).to(4)
      end

      it 'updates the last_interaction_at timestamp of the cart' do
        expect { service }.to change { cart.reload.last_interaction_at }
      end
    end

    context 'when the product does not exist' do
      let(:service) { described_class.new(cart: cart, product_id: 9999, quantity: 1) }

      it 'returns false' do
        expect(service.call).to be_falsey
      end
    end
  end
end

