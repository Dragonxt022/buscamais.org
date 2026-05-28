class AddPremiumToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :premium, :boolean, default: false, null: false
  end
end
