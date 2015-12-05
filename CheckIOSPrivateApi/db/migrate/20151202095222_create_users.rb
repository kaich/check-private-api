class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :token
      t.string :class_path
      t.string :class_name
      t.string :init_method
      t.string :call_methods

      t.timestamps null: false
    end
    add_index :users, :name , unique: true
  end
end
