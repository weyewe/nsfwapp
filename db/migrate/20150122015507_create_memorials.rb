class CreateMemorials < ActiveRecord::Migration
  def change
    create_table :memorials do |t|
      
      
      t.datetime :transaction_datetime
      t.text :description 

      # debit amount must be equal to credit amount.. ahahaha awesome shite 
      t.boolean :is_confirmed , :default => false  # can only be confirmed if debit == credit.. hahaha.
      t.datetime :confirmed_at 
      t.string :code 
      
      t.boolean :is_deleted, :default => false 
      t.datetime :deleted_at 
  
      t.timestamps
    end
  end
end
