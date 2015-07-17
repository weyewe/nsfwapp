class AddSavingsStatusToGroupLoanWeeklyCollectionVoluntarySavings < ActiveRecord::Migration
  def change
    add_column :group_loan_weekly_collection_voluntary_savings_entries, :direction  , :integer , :default =>FUND_TRANSFER_DIRECTION[:incoming] 
  end
end
