class AddTentativeCollectionDateToGroupLoanWeeklyCollection < ActiveRecord::Migration
  def change
    add_column :group_loan_weekly_collections,  :tentative_collection_date , :datetime
  end
end
