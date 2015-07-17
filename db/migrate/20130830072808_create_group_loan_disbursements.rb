class CreateGroupLoanDisbursements < ActiveRecord::Migration
  def change
    create_table :group_loan_disbursements do |t|
      
      t.integer :group_loan_membership_id 
      t.integer :group_loan_id 
      
      
      t.timestamps
    end
  end
end
