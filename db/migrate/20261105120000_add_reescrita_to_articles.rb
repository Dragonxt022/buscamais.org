class AddReescritaToArticles < ActiveRecord::Migration[8.1]
  def change
    # "processando" = reprocessamento manual em andamento
    # "reescrito"   = passou pela IA e o texto publicado é original
    # "falhou"      = IA habilitada, mas falhou/recusou; entrou para revisão
    # "desativada"  = feed sem reescrita automática
    add_column :articles, :reescrita_status, :string
    add_column :articles, :reescrita_modelo, :string
    add_index :articles, :reescrita_status
  end
end
