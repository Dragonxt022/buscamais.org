class AddLegendaCapaToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :legenda_capa, :string
  end
end
