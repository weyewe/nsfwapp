class GroupLoanWeeklyPayment < ActiveRecord::Base
  attr_accessible :group_loan_membership_id, :group_loan_id, :group_loan_weekly_collection_id, :is_run_away_weekly_bailout
  
  has_many :transaction_activities, :as => :transaction_source 
  has_many :savings_entries, :as => :savings_source
  
  belongs_to :group_loan_membership
  belongs_to :group_loan
  belongs_to :group_loan_weekly_collection 
  
  after_create :create_transaction_activities , :create_compulsory_savings
  
  def create_transaction_activities  
    
     
    member = group_loan_membership.member 
    
    # Weekly payment 
    TransactionActivity.create :transaction_source_id => self.id, 
                              :transaction_source_type => self.class.to_s,
                              :amount => group_loan_membership.group_loan_product.weekly_payment_amount ,
                              :direction => FUND_TRANSFER_DIRECTION[:incoming],
                              :member_id => member.id,
                              :fund_case => FUND_TRANSFER_CASE[:cash]
     
  end
  
  def create_compulsory_savings 
    
    # puts "Calling compulsory savings"
    if group_loan_membership.group_loan_product.compulsory_savings != BigDecimal('0')
      SavingsEntry.create_weekly_payment_compulsory_savings( self )
    end
    
  end
  
  def delete_object
    # delete transaction_activity
    
    # delete savings_entry => compulsory_savings
     
      glm = self.group_loan_membership 
      # delete transaction_activity
      TransactionActivity.where(
        :transaction_source_id => self.id, 
        :transaction_source_type => self.class.to_s
      ).each {|x| x.destroy }
                                
                                
      # SavingsEntry.create_weekly_payment_compulsory_savings( self )
      total_amount = BigDecimal("0")
      SavingsEntry.where(
        :savings_source_id => self.id,
        :savings_source_type => self.class.to_s,
        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
        :direction => FUND_TRANSFER_DIRECTION[:incoming],
        :financial_product_id => self.group_loan_id ,
        :financial_product_type => self.group_loan.class.to_s
      ).each do |savings_entry|
        total_amount += savings_entry.amount 
        savings_entry.destroy
      end
      
      glm.update_total_compulsory_savings( -1*total_amount)
      
      self.destroy 
    
    
  end
  
   
end
