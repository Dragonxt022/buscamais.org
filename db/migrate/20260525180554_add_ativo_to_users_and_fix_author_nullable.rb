class AddAtivoToUsersAndFixAuthorNullable < ActiveRecord::Migration[8.1]
  def change
    # Permite author_id nulo para que dependent: :nullify funcione ao deletar usuário
    change_column_null :articles, :author_id, true

    # Campo para ativar/desativar usuário sem deletar
    add_column :users, :ativo, :boolean, default: true, null: false
    add_index  :users, :ativo
  end
end
