class CreateApiResults < ActiveRecord::Migration
  def change
    create_table :api_results do |t|
      t.string :user_name
      t.string :class_path
      t.string :class_name
      t.string :init_method 
      t.string :call_methods    
      t.string :result

      t.timestamps null: false
    end
  end
end
