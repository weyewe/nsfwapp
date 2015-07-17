class CreateGroupLoanWeeklyPayments < ActiveRecord::Migration
  def change
    create_table :group_loan_weekly_payments do |t|
      t.integer :group_loan_membership_id
      t.integer :group_loan_id
      t.integer :group_loan_weekly_collection_id 
      
      t.boolean :is_run_away_weekly_bailout , :default => false 
# is_run_away_bail_out
      t.timestamps
    end
  end
end
