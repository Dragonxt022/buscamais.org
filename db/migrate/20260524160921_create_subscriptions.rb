class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :plano, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.date    :prox_cobranca
      t.decimal :valor, precision: 8, scale: 2

      t.timestamps
    end
  end
end
