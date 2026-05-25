class CreateMediaFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :media_files do |t|
      t.string :nome
      t.string :tipo
      t.integer :tamanho
      t.integer :largura
      t.integer :altura
      t.text :descricao
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
