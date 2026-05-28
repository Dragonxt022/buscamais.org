class AddPromocaoToSubscriptionPlans < ActiveRecord::Migration[8.1]
  def change
    add_column :subscription_plans, :promocao_ativa,        :boolean, default: false, null: false
    add_column :subscription_plans, :preco_promocional,     :decimal, precision: 8, scale: 2
    add_column :subscription_plans, :meses_promocionais,    :integer, default: 3
    add_column :subscription_plans, :stripe_promo_price_id, :string
    add_column :subscription_plans, :apenas_novos_usuarios, :boolean, default: true, null: false
  end
end
