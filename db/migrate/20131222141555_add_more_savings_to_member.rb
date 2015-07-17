class AddMoreSavingsToMember < ActiveRecord::Migration
  def change
    
    add_column :members, :total_membership_savings  , :decimal ,  :precision => 12 , :scale => 2 , :default => BigDecimal('0')
  end
end
