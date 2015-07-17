class CreateGroupLoanWeeklyCollections < ActiveRecord::Migration
  def change
    create_table :group_loan_weekly_collections do |t|
      t.integer :group_loan_id 
      t.integer :week_number 
      t.boolean :is_collected, :default => false 
      
      
      t.decimal :premature_clearance_deposit_usage, :default       => 0, :precision => 10, :scale => 2
      t.boolean :is_confirmed, :default => false 
      
      t.datetime :collected_at   # explicit, has to be selected by the loan officer 
      
      t.datetime :confirmed_at # explicit as well 
      
      

      t.timestamps
    end
  end
end
