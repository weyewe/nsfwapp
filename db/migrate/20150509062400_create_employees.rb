class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|

      t.integer :branch_id 
      t.string :name 
      t.string :code 
      t.string :description 

      # t.integer :title 

      t.timestamps
    end
  end
end
