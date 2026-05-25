class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :nome, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :tags, :slug, unique: true
    add_index :tags, :nome, unique: true
  end
end
