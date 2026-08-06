class CreateAlbums < ActiveRecord::Migration[8.1]
  def change
    create_table :albums do |t|
      t.string :nome, null: false
      t.text :descricao
      t.references :user, null: false, foreign_key: true
      t.bigint :capa_media_file_id

      t.timestamps
    end
  end
end
