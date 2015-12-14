class CreateApiResults < ActiveRecord::Migration
  def change
    create_table :api_results do |t|
      t.string :title
      t.text :content
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
