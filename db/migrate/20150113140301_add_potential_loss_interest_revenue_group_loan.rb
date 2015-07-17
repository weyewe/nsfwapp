class AddPotentialLossInterestRevenueGroupLoan < ActiveRecord::Migration
  def change
    add_column :group_loans, :potential_loss_interest_revenue  , :decimal ,  :precision => 12, :scale => 2  , :default => BigDecimal('0')
    
  end
end
