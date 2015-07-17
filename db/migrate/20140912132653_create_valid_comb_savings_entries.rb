class CreateValidCombSavingsEntries < ActiveRecord::Migration
  def change
    create_table :valid_comb_savings_entries do |t|
      
      t.integer :member_id
      t.integer :month
      t.integer :year
      t.integer :savings_status
      t.decimal :amount  , :default        => 0,  :precision => 12, :scale => 2
      

      t.timestamps
    end
  end
end
