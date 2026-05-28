class CreateCommentReports < ActiveRecord::Migration[8.1]
  def change
    create_table :comment_reports do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.string  :reason,     null: false, default: "spam"
      t.text    :descricao
      t.boolean :resolvido,  null: false, default: false
      t.timestamps
    end
    add_index :comment_reports, [:user_id, :comment_id], unique: true
  end
end
