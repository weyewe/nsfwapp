class CompleteMemberData < ActiveRecord::Migration
  def change
    
    add_column :members,  :id_card_number, :string
    
    add_column :members,  :birthday_date, :datetime
    add_column :members, :is_data_complete, :boolean ,  :default => false
    
    add_column :members, :total_locked_savings_account  , :decimal ,  :precision => 12, :scale => 2  , :default => BigDecimal('0') 
  end
end
