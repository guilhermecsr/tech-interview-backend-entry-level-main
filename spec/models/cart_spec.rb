require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'associations' do
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:products).through(:cart_items) }
  end

  describe '#total_price' do
    it 'calculates the total price of all items in the cart' do
      cart = create(:cart)
      product1 = create(:product, price: 10.0)
      product2 = create(:product, price: 5.0)
      create(:cart_item, cart: cart, product: product1, quantity: 2)
      create(:cart_item, cart: cart, product: product2, quantity: 3)

      expect(cart.total_price).to eq(35.0)
    end

    it 'returns 0 if the cart is empty' do
      cart = create(:cart)
      expect(cart.total_price).to eq(0)
    end
  end


  describe 'enums' do
    it { should define_enum_for(:status).with_values(active: 0, abandoned: 1) }
  end

  describe 'scopes' do
    before { Timecop.freeze(Time.current) }
    after { Timecop.return }

    describe '.inactive_for_3_hours' do
      it 'includes active carts with last interaction over 3 hours ago' do
        inactive_cart = create(:cart, status: :active, last_interaction_at: 4.hours.ago)

        expect(Cart.inactive_for_3_hours).to include(inactive_cart)
      end

      it 'excludes active carts with recent interaction' do
        active_cart = create(:cart, status: :active, last_interaction_at: 1.hour.ago)

        expect(Cart.inactive_for_3_hours).not_to include(active_cart)
      end

      it 'excludes already abandoned carts' do
        abandoned_cart = create(:cart, status: :abandoned, last_interaction_at: 4.hours.ago)

        expect(Cart.inactive_for_3_hours).not_to include(abandoned_cart)
      end
    end

    describe '.abandoned_for_7_days' do
      it 'includes abandoned carts that were marked over 7 days ago' do
        old_abandoned_cart = create(:cart, status: :abandoned, abandoned_at: 8.days.ago)

        expect(Cart.abandoned_for_7_days).to include(old_abandoned_cart)
      end

      it 'excludes abandoned carts that were marked recently' do
        recent_abandoned_cart = create(:cart, status: :abandoned, abandoned_at: 1.day.ago)

        expect(Cart.abandoned_for_7_days).not_to include(recent_abandoned_cart)
      end
    end
  end
end
