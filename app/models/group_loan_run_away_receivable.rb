class GroupLoanRunAwayReceivable < ActiveRecord::Base
  attr_accessible :member_id, :amount_receivable, 
                  :group_loan_id, :payment_case , :group_loan_membership_id , 
                  :group_loan_weekly_collection_id
  # has_many :group_loan_run_away_receivable_payments
  belongs_to :group_loan_membership 
  belongs_to :group_loan_weekly_collection
  belongs_to :member
  
  validate :valid_payment_case
  validates_presence_of :payment_case
  
  belongs_to :group_loan 
  
  # after_create :update_group_loan_run_away_amount_receivable  
  after_create :perform_run_away_declaration_posting
  
  def valid_payment_case
    return if not payment_case.present?
      
      
    array = [
        GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly],
        GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]
      ]
      
    if not array.include?( payment_case.to_i )
      self.errors.add(:payment_case, "Metode Penagihan tidak valid")
    end
    
  end
  
  def perform_run_away_declaration_posting
    
    AccountingService::MemberRunAway.create_bad_debt_allocation(
        group_loan, 
        member, 
        group_loan_membership, 
        group_loan_weekly_collection,
        self) 
  end
  
    
  
  def set_payment_case( params ) 
    # if self.group_loan_run_away_receivable_payments.count != 0 
    #   self.errors.add(:generic_errors, "Sudah ada pembayaran")
    #   return self 
    # end
    
    if self.group_loan_weekly_collection.is_collected? || 
       self.group_loan_weekly_collection.is_confirmed? 
         self.errors.add(:generic_errors, "Sudah konfirmasi pembayaran mingguan")
         return self 
    end
    
    # if the week when this payment has been reported has been confirmed... then, 
    # you can't change anymore 
    
    self.payment_case = params[:payment_case]
    self.save  
  end
  
   
  
  
end
