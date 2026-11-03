class AddSourceCreditToFeeds < ActiveRecord::Migration[8.1]
  def change
    add_column :feed_sources, :creditar_fonte, :boolean, default: false, null: false
    add_column :articles, :mostrar_fonte, :boolean, default: false, null: false
  end
end
