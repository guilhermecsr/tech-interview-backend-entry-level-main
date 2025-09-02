RSpec.describe Carts::Create do
  let(:cart) { create(:cart) }
  let(:product) { create(:product) }
  let(:quantity) { 2 }

  subject(:service) { described_class.new(cart: cart, product_id: product.id, quantity: quantity).call }

  describe '#call' do
    context 'when adding a new product to the cart' do
      it 'returns true' do
        expect(service).to be_truthy
      end

      it 'creates a new CartItem' do
        expect { service }.to change(CartItem, :count).by(1)
      end

      it 'sets the correct quantity for the new item' do
        service
        expect(cart.cart_items.last.quantity).to eq(quantity)
      end

      it 'updates the last_interaction_at timestamp of the cart' do
        expect { service }.to change { cart.reload.last_interaction_at }
      end
    end

    context 'when adding a product that already exists in the cart' do
      let!(:existing_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }
      let(:quantity) { 3 }

      it 'returns true' do
        expect(service).to be_truthy
      end

      it 'does not create a new CartItem' do
        expect { service }.not_to change(CartItem, :count)
      end

      it 'updates the quantity of the existing item' do
        expect { service }.to change { existing_item.reload.quantity }.from(1).to(4)
      end
    end

    context 'when the product does not exist' do
      let(:invalid_product_id) { 9999 }
      subject(:service) { described_class.new(cart: cart, product_id: invalid_product_id, quantity: 1).call }

      it 'returns false' do
        expect(service).to be_falsey
      end
    end

    context 'when the quantity is invalid (zero or negative)' do
      let(:quantity) { 0 }

      it 'returns false' do
        expect(service).to be_falsey
      end

      it 'does not change the database' do
        expect { service }.not_to change(CartItem, :count)
      end
    end

    context 'when saving the CartItem fails' do
      before do
        allow_any_instance_of(CartItem).to receive(:increment!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'returns false' do
        expect(service).to be_falsey
      end
    end
  end
end

