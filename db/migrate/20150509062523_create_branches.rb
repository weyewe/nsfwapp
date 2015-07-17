class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|

      t.string :name 
      t.text :description 
      t.text :address
      t.string :code 

      t.integer :branch_head_id 

      t.timestamps
    end
  end
end
