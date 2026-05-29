class CreateSubscriptionHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :subscription_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscription_plan, null: true, foreign_key: true
      t.string :event_type
      t.decimal :valor
      t.string :status
      t.string :stripe_subscription_id
      t.datetime :vigente_de
      t.datetime :vigente_ate

      t.timestamps
    end
  end
end
