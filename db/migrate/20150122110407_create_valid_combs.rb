class CreateValidCombs < ActiveRecord::Migration
  def change
    create_table :valid_combs do |t|
      
      t.integer :closing_id
      t.integer :account_id 
      
      t.decimal :amount, :default        => 0,  :precision => 14, :scale => 2
      
      t.integer :entry_case 
      
      

      t.timestamps
    end
  end
end
