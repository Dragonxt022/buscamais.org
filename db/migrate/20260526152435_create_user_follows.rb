class CreateUserFollows < ActiveRecord::Migration[8.1]
  def change
    create_table :user_follows do |t|
      t.bigint  :follower_id,      null: false
      t.string  :followable_type,  null: false
      t.bigint  :followable_id,    null: false
      t.timestamps
    end
    add_index :user_follows, :follower_id
    add_index :user_follows, [:followable_type, :followable_id]
    add_index :user_follows, [:follower_id, :followable_type, :followable_id], unique: true, name: "idx_user_follows_unique"
  end
end
