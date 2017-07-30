class AddColumnToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :chatroom_id, :integer
  end
end
