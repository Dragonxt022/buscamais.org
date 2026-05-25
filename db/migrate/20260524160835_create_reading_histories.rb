class CreateReadingHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :reading_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true
      t.datetime :lido_em, null: false

      t.timestamps
    end

    add_index :reading_histories, [:user_id, :article_id], unique: true
    add_index :reading_histories, :lido_em
  end
end
