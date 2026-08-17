class AddAreaAtuacaoToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :area_atuacao, :string
  end
end
