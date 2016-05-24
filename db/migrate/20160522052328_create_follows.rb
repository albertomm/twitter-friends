class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.integer :user_id, null: false
      t.integer :friend_id, null: false
      t.foreign_key :users, column: :user_id
      t.foreign_key :users, column: :friend_id
      t.index [:user_id, :friend_id], unique: true
      t.timestamps null: false
    end
  end
end
