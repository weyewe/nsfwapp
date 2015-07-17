class AddMessageToSavingsEntry < ActiveRecord::Migration
  def change
    add_column :savings_entries, :message  , :string 
    
    
    
  end
end
