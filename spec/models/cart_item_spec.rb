require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:cart) }
    it { is_expected.to belong_to(:product) }
  end

  describe '#total_price' do
    let(:product) { create(:product, price: 15.0) }
    let(:cart_item) { create(:cart_item, product: product, quantity: 3) }

    subject { cart_item.total_price }

    it 'returns the product price multiplied by the quantity' do
      is_expected.to eq(45.0)
    end
  end
end
