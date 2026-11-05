class AddReescritaAutomaticaToFeedSources < ActiveRecord::Migration[8.1]
  def change
    add_column :feed_sources, :reescrita_automatica, :boolean, default: true, null: false
  end
end
