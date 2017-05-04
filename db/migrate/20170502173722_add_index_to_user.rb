class AddIndexToUser < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :password_digest
  end
end
