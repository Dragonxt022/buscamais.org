class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string  :titulo, null: false
      t.string  :slug, null: false
      t.text    :conteudo
      t.text    :resumo
      t.integer :status, default: 0, null: false
      t.boolean :destaque, default: false, null: false
      t.integer :visualizacoes, default: 0, null: false
      t.integer :tempo_leitura, default: 0
      t.string  :imagem_capa
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :category, null: true, foreign_key: true
      t.datetime :publicado_em
      t.datetime :agendado_em

      t.timestamps
    end

    add_index :articles, :slug, unique: true
    add_index :articles, :status
    add_index :articles, :destaque
    add_index :articles, :publicado_em
  end
end
