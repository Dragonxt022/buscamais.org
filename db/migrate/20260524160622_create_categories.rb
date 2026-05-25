class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :nome, null: false
      t.string :slug, null: false
      t.text :descricao
      t.string :cor, default: "#1a56db"
      t.boolean :ativo, default: true, null: false

      t.timestamps
    end

    add_index :categories, :slug, unique: true
    add_index :categories, :nome, unique: true
  end
end
