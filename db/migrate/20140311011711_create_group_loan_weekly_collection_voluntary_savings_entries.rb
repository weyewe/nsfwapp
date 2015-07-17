class CreateGroupLoanWeeklyCollectionVoluntarySavingsEntries < ActiveRecord::Migration
  def change
    create_table :group_loan_weekly_collection_voluntary_savings_entries do |t|
      
      t.decimal :amount, :default       => 0, :precision => 10, :scale => 2
      t.integer :group_loan_membership_id
      t.integer :group_loan_weekly_collection_id
      

      t.timestamps
    end
  end
end
