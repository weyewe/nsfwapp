class CreateSavingsEntries < ActiveRecord::Migration
  def change
    create_table :savings_entries do |t|
      t.integer :savings_source_id 
      t.string :savings_source_type
      t.decimal :amount  , :default        => 0,  :precision => 10, :scale => 2 
      t.integer :savings_status
      t.integer :direction
      
      t.integer :financial_product_id
      t.string :financial_product_type 
      
      t.integer :member_id 
      
      t.text :description 
      
      
      t.boolean :is_confirmed, :default => false 
      t.datetime :confirmed_at 

      t.timestamps
    end
  end
end
