class AddParentIdAndLikesCountToComments < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :parent_id, :integer, null: true
    add_column :comments, :likes_count, :integer, default: 0, null: false
    add_index  :comments, :parent_id
  end
end
