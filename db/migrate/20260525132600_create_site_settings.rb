class CreateSiteSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :site_settings do |t|
      t.string :chave, null: false
      t.text   :valor
      t.timestamps
    end
    add_index :site_settings, :chave, unique: true
  end
end
