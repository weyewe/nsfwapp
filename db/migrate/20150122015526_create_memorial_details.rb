class CreateMemorialDetails < ActiveRecord::Migration
  def change
    create_table :memorial_details do |t|

      t.datetime :transaction_datetime 
      
      t.integer :memorial_id
      t.integer :transaction_data_id 
      t.integer :account_id
      
      t.integer :entry_case # NORMAL_BALANCE[:debit] or [:credit]
      t.decimal :amount, :default        => 0,  :precision => 14, :scale => 2
      
      t.string :description 
      
      
      t.timestamps
    end
  end
end
