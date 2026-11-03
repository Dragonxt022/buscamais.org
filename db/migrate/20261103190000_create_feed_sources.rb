class CreateFeedSources < ActiveRecord::Migration[8.1]
  def change
    create_table :feed_sources do |t|
      t.string  :nome, null: false
      t.string  :url, null: false
      t.boolean :ativo, default: true, null: false
      t.integer :intervalo_minutos, default: 60, null: false
      t.boolean :publicar_automaticamente, default: true, null: false
      t.boolean :importar_imagem, default: true, null: false
      t.integer :limite_por_sincronizacao, default: 10, null: false
      t.references :category, null: true, foreign_key: true
      t.references :author, null: true, foreign_key: { to_table: :users }
      t.datetime :ultima_sincronizacao_em
      t.string   :ultimo_status
      t.text     :ultima_mensagem
      t.integer  :total_importados, default: 0, null: false
      t.timestamps
    end
    add_index :feed_sources, :url, unique: true

    add_reference :articles, :feed_source, null: true, foreign_key: true
    add_column :articles, :external_id, :string
    add_column :articles, :fonte_nome, :string
    add_column :articles, :fonte_url, :string
    add_index :articles, [ :feed_source_id, :external_id ], unique: true
    add_index :articles, :fonte_url
  end
end
