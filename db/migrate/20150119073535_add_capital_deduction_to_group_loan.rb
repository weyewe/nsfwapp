class AddCapitalDeductionToGroupLoan < ActiveRecord::Migration
  def change
    add_column :group_loans, :bad_debt_allowance_capital_deduction  , :decimal ,  :precision => 12, :scale => 2  , :default => BigDecimal('0')
    add_column :group_loans, :interest_revenue_capital_deduction  , :decimal ,  :precision => 12, :scale => 2  , :default => BigDecimal('0')
  end
end
