class AddStripeAndPlanToSubscriptions < ActiveRecord::Migration[8.1]
  def change
    add_column :subscriptions, :stripe_customer_id,     :string
    add_column :subscriptions, :stripe_subscription_id, :string
    add_column :subscriptions, :subscription_plan_id,   :bigint
    add_index  :subscriptions, :stripe_customer_id
    add_index  :subscriptions, :subscription_plan_id
  end
end
