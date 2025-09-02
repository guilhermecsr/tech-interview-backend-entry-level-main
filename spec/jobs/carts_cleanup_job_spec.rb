require 'rails_helper'

RSpec.describe CartsCleanupJob, type: :job do
  before { Timecop.freeze(Time.current) }
  after { Timecop.return }

  let!(:active_cart_ok) { create(:cart, status: :active, last_interaction_at: 1.hour.ago) }
  let!(:active_cart_to_abandon) { create(:cart, status: :active, last_interaction_at: 4.hours.ago) }
  let!(:abandoned_cart_ok) { create(:cart, status: :abandoned, abandoned_at: 1.day.ago) }
  let!(:abandoned_cart_to_delete) { create(:cart, status: :abandoned, abandoned_at: 8.days.ago) }

  it "marks old active carts as abandoned and removes very old abandoned carts" do
    described_class.new.perform

    expect(active_cart_ok.reload.status).to eq('active')
    expect(active_cart_to_abandon.reload.status).to eq('abandoned')
    expect(active_cart_to_abandon.reload.abandoned_at).to be_within(1.second).of(Time.current)
    expect(Cart.exists?(abandoned_cart_ok.id)).to be_truthy
    expect(Cart.exists?(abandoned_cart_to_delete.id)).to be_falsey
  end
end
