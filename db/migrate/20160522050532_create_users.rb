class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false, limit: 15
      t.index :name, unique: true
      t.datetime :last_update, null: false, default: 0
      t.index :last_update
    end
  end
end
