class CreateGroupLoanWeeklyCollectionAttendances < ActiveRecord::Migration
  def change
    create_table :group_loan_weekly_collection_attendances do |t|
    	t.integer :group_loan_weekly_collection_id
    	t.integer :group_loan_membership_id
    	t.boolean :attendance_status    , :default => true 
    	t.boolean :payment_status , :default => true 

      t.timestamps
    end
  end
end
