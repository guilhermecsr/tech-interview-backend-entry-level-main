class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  enum status: { active: 0, abandoned: 1 }

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  scope :inactive_for_3_hours, -> { active.where('last_interaction_at < ?', 3.hours.ago) }
  scope :abandoned_for_7_days, -> { abandoned.where('abandoned_at < ?', 7.days.ago) }

  def mark_as_abandoned
    update(status: :abandoned, abandoned_at: Time.current)
  end

  def total_price
    cart_items.reload.to_a.sum(&:total_price)
  end
end

