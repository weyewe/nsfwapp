class CreateGroupLoanWeeklyUncollectibles < ActiveRecord::Migration
  def change
    create_table :group_loan_weekly_uncollectibles do |t|
      t.integer :group_loan_weekly_collection_id 
      t.integer :group_loan_membership_id 
      t.integer :group_loan_id 
      
      t.decimal :amount , :default        => 0,  :precision => 12, :scale => 2 
      t.decimal :principal , :default        => 0,  :precision => 12, :scale => 2 
      
      t.boolean :is_collected, :default => false 
      t.datetime :collected_at 
      
      t.integer :clearance_case, :default => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
      
      t.boolean :is_cleared, :default => false 
      t.datetime :cleared_at   # (independent)
      
      
      
      # how is the clearance mechanism?
      # field officer collect payment.. produce receipt. And cashier confirm. 
      
       

      t.timestamps
    end
  end
end
