class CreateApiResults < ActiveRecord::Migration
  def change
    create_table :api_results do |t|
      t.string :user_name
      t.string :class_path
      t.string :class_name
      t.string :init_method 
      t.string :call_methods    
      t.string :device_name
      t.string :device_model
      t.string :device_os_version
      t.string :device_adfa
      t.string :result

      t.timestamps null: false
    end
  end
end
