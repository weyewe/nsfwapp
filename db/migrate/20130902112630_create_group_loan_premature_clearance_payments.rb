class CreateGroupLoanPrematureClearancePayments < ActiveRecord::Migration
  def change
    create_table :group_loan_premature_clearance_payments do |t|
      t.integer :group_loan_id
      t.integer :group_loan_membership_id 
      t.integer :group_loan_weekly_collection_id 
      
      
      # the amount is calculated value  => the update 
      # mechanism is kinda fancy. Use group loan default payment
      t.decimal :amount , :default        => 0,  :precision => 12, :scale => 2 
      # t.decimal :principal_return , :default        => 0,  :precision => 12, :scale => 2 
      # t.decimal :run_away_contribution , :default        => 0,  :precision => 12, :scale => 2 
      
      t.boolean :is_confirmed, :default => false 
      
      # maybe there is nothing useful on this
      # t.decimal :premature_clearance_deposit , :default        => 0,  :precision => 12, :scale => 2 
      
      
      
      # on premature clearance, the payment amount is deducted by compulsory savings
      # if there is remaining compulsory savings, it will be ported to savings_account
      # withdrawn separately. 
      t.decimal :remaining_compulsory_savings , :default        => 0,  :precision => 12, :scale => 2 
      
      t.timestamps
    end
  end
end
