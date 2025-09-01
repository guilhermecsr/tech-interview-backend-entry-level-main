class AddStatusToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :status, :integer, default: 0
    add_column :carts, :last_interaction_at, :datetime
    add_column :carts, :abandoned_at, :datetime
  end
end
