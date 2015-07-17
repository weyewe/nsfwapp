class AddIsAdjustmentToSavingsEntries < ActiveRecord::Migration
  def change
    add_column :savings_entries, :is_adjustment, :boolean,  :default => false 
  end
end
