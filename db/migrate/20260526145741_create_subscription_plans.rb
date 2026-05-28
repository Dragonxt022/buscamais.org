class CreateSubscriptionPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :subscription_plans do |t|
      t.string  :nome,      null: false
      t.string  :slug,      null: false
      t.text    :descricao
      t.decimal :preco,     precision: 8, scale: 2, default: "0.0"
      t.integer :posicao,   default: 0
      t.boolean :destaque,  default: false, null: false
      t.boolean :ativo,     default: true,  null: false
      t.string  :cor,       default: "blue"
      t.json    :beneficios
      t.json    :permissoes

      t.timestamps
    end

    add_index :subscription_plans, :slug, unique: true
    add_index :subscription_plans, :posicao
  end
end
