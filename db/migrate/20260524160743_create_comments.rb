class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.text    :conteudo, null: false
      t.integer :status, default: 0, null: false
      t.references :user, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true
      t.integer :aprovado_por

      t.timestamps
    end

    add_index :comments, :status
  end
end
