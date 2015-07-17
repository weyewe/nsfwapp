class CreateGroupLoanRunAwayReceivables < ActiveRecord::Migration
  def change
    create_table :group_loan_run_away_receivables do |t|
      t.integer :member_id
      t.integer :group_loan_membership_id
      t.integer :group_loan_id 
      
      t.integer :group_loan_weekly_collection_id 
      
      
      t.decimal :amount_receivable , :default     => 0,  :precision => 12, :scale => 2 
      # t.decimal :amount_received , :default       => 0,  :precision => 12, :scale => 2 
      
      
      
      t.boolean :is_closed, :default => false 
      
      # they can choose whether it is paid weekly or @end_of_cycle. 
      t.integer :payment_case   
      

      t.timestamps
    end
  end
end
