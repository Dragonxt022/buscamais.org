class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user,           null: false, foreign_key: true
      t.string     :notificable_type
      t.bigint     :notificable_id
      t.string     :tipo,           null: false
      t.boolean    :lida,           null: false, default: false
      t.text       :dados
      t.timestamps
    end
    add_index :notifications, [:notificable_type, :notificable_id]
    add_index :notifications, [:user_id, :lida]
  end
end
