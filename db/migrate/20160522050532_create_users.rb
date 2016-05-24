class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false, limit: 15
      t.index :name, unique: true
      t.timestamps null: false
    end
  end
end
