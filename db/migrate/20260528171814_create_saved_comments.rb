class CreateSavedComments < ActiveRecord::Migration[8.1]
  def change
    create_table :saved_comments do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.timestamps
    end
    add_index :saved_comments, [:user_id, :comment_id], unique: true
  end
end
