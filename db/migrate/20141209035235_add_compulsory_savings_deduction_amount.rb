class AddCompulsorySavingsDeductionAmount < ActiveRecord::Migration
  def change
    add_column :group_loans, :compulsory_savings_deduction_amount, :decimal ,  :precision => 12 , :scale => 2 , :default => BigDecimal('0')
  end
end
