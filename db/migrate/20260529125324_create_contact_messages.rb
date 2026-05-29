class CreateContactMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_messages do |t|
      t.string :nome
      t.string :email
      t.string :assunto
      t.text :mensagem
      t.boolean :lida,       default: false, null: false
      t.boolean :respondida, default: false, null: false
      t.text :resposta
      t.datetime :respondida_em

      t.timestamps
    end
  end
end
