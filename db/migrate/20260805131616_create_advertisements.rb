class CreateAdvertisements < ActiveRecord::Migration[8.1]
  def change
    create_table :advertisements do |t|
      t.string :titulo, null: false
      t.string :url_destino, null: false
      t.integer :formato, null: false, default: 0
      t.boolean :ativo, null: false, default: true
      t.datetime :inicio_em
      t.datetime :fim_em
      t.integer :cliques, null: false, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :advertisements, [:formato, :ativo]
  end
end
