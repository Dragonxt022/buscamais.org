class CreateSiteBrandings < ActiveRecord::Migration[8.1]
  def change
    create_table :site_brandings do |t|
      t.timestamps
    end
  end
end
