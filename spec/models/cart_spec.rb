require 'rails_helper'

RSpec.describe Cart, type: :model do
  subject(:cart) { described_class.new }

  context 'when validating' do
    subject(:cart) { described_class.new(total_price: -1) }

    it 'is invalid with a negative total_price' do
      expect(cart).not_to be_valid
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe '#mark_as_abandoned' do
    let(:shopping_cart) { create(:cart, last_interaction_at: 3.hours.ago) }

    it 'marks the shopping cart as abandoned' do
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:cart_items).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:cart_items) }
  end

  describe '#current_total_price' do
    let(:cart) { create(:cart) }

    context 'when the cart has items' do
      let(:product1) { create(:product, price: 10.0) }
      let(:product2) { create(:product, price: 5.0) }
      let!(:cart_item1) { create(:cart_item, cart: cart, product: product1, quantity: 2) }
      let!(:cart_item2) { create(:cart_item, cart: cart, product: product2, quantity: 3) }

      it 'calculates the total price of all items' do
        expect(cart.current_total_price).to eq(35.0)
      end
    end

    context 'when the cart is empty' do
      it 'returns 0' do
        expect(cart.total_price).to eq(0)
      end
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(active: 0, abandoned: 1) }
  end

  describe 'scopes' do
    before { Timecop.freeze(Time.current) }
    after { Timecop.return }

    describe '.inactive_for_3_hours' do
      let!(:inactive_cart) { create(:cart, status: :active, last_interaction_at: 4.hours.ago) }
      let!(:active_cart) { create(:cart, status: :active, last_interaction_at: 1.hour.ago) }
      let!(:abandoned_cart) { create(:cart, status: :abandoned, last_interaction_at: 4.hours.ago) }

      subject(:scope_result) { described_class.inactive_for_3_hours }

      it 'includes active carts with last interaction over 3 hours ago' do
        expect(scope_result).to include(inactive_cart)
      end

      it 'excludes active carts with recent interaction' do
        expect(scope_result).not_to include(active_cart)
      end

      it 'excludes already abandoned carts' do
        expect(scope_result).not_to include(abandoned_cart)
      end
    end

    describe '.abandoned_for_7_days' do
      let!(:old_abandoned_cart) { create(:cart, status: :abandoned, abandoned_at: 8.days.ago) }
      let!(:recent_abandoned_cart) { create(:cart, status: :abandoned, abandoned_at: 1.day.ago) }

      subject(:scope_result) { described_class.abandoned_for_7_days }

      it 'includes abandoned carts that were marked over 7 days ago' do
        expect(scope_result).to include(old_abandoned_cart)
      end

      it 'excludes abandoned carts that were marked recently' do
        expect(scope_result).not_to include(recent_abandoned_cart)
      end
    end
  end
end
