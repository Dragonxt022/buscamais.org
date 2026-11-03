class AddPalavraChaveFocoToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :palavra_chave_foco, :string
  end
end
