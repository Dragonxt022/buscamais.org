class AddStripePriceIdToSubscriptionPlans < ActiveRecord::Migration[8.1]
  def change
    add_column :subscription_plans, :stripe_price_id, :string
  end
end
