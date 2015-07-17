class AddUnpaidInterestRevenueAndBadDebtAllowanceToGroupLoanMembership < ActiveRecord::Migration
  def change
    #add_column :group_loan_memberships, :potential_loss_interest_revenue  , :decimal ,  :precision => 12, :scale => 2  , :default => BigDecimal('0')
    # add_column :group_loan_memberships, :personal_bad_debt_allowance  , :decimal ,  :precision => 12, :scale => 2  , :default => BigDecimal('0')
    add_column :group_loan_memberships, :compulsory_savings_deduction_for_interest_revenue  , :decimal ,  :precision => 12, :scale => 2  , :default => BigDecimal('0')
    add_column :group_loan_memberships, :compulsory_savings_deduction_for_bad_debt_allowance  , :decimal ,  :precision => 12, :scale => 2  , :default => BigDecimal('0')
    
    # to close the bad_debt_expense
    add_column :group_loan_memberships, :closing_bad_debt_expense  , :decimal ,  :precision => 12, :scale => 2  , :default => BigDecimal('0')
  end
end
