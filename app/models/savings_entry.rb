# this is the backbone to track savings, any kind of savings
# group_loan_compulsory_savings, group_loan_voluntary_savings 
# normal_savings_account (with interest monthly)
# and even savings withdrawal

class SavingsEntry < ActiveRecord::Base
  attr_accessible :savings_source_id, 
                  :savings_source_type,
                  :amount,
                  :savings_status,
                  :direction,
                  
                  :financial_product_id,
                  :financial_product_type ,
                  :member_id ,
                  :description,
                  :is_confirmed ,
                  :confirmed_at ,
                  :is_adjustment ,
                  :message
                  
  validates_presence_of :direction, :amount, :member_id 
  
  belongs_to :savings_source, :polymorphic => true
  belongs_to :financial_product, :polymorphic => true 
  
  belongs_to :member 
  
  validate :valid_direction_if_independent_savings
  validate :valid_amount 
  validate :valid_withdrawal_amount
  
  def all_fields_for_independent_savings_present?
    direction.present? and 
    amount.present? and 
    member_id.present? 
  end

  def valid_direction_if_independent_savings
    return if not financial_product_id.nil?
    return if not all_fields_for_independent_savings_present?
    
    
    if not [
        FUND_TRANSFER_DIRECTION[:incoming],
        FUND_TRANSFER_DIRECTION[:outgoing]
      ].include?(self.direction)
      self.errors.add(:direction, "Harus memilih tipe transaksi: penambahan atau pengurangan")
      return self 
    end
  end
  
  def valid_amount
    return if not financial_product_id.nil?
    return if not all_fields_for_independent_savings_present?
    
    if amount <= BigDecimal('0')
      self.errors.add(:amount, "Jumlah tidak boleh sama dengan atau lebih kecil dari 0")
      return self
    end
  end
  
  def valid_withdrawal_amount
    
    # puts "Checking valid withdrawal amount\n"*5
    
    return if not financial_product_id.nil?
    # puts "financial product id is nil"
    return if not all_fields_for_independent_savings_present?
    # puts "Every needed data is present"
    
    return if self.is_confirmed? 
    
    
    if direction == FUND_TRANSFER_DIRECTION[:outgoing]
      # puts "Amount: #{amount}"
      # puts "Total savings: #{member.total_savings_account}"
      if self.savings_status == SAVINGS_STATUS[:savings_account] and amount > member.total_savings_account
        self.errors.add(:amount, "Tidak boleh lebih besar dari #{member.total_savings_account}")
        return self 
      end
      
      
      
      if self.savings_status == SAVINGS_STATUS[:membership] and amount > member.total_membership_savings
        self.errors.add(:amount, "Tidak boleh lebih besar dari #{member.total_membership_savings}")
        return self 
      end
      
      if self.savings_status == SAVINGS_STATUS[:locked] and amount > member.total_locked_savings_account
        self.errors.add(:amount, "Tidak boleh lebih besar dari #{member.total_locked_savings_account}")
        return self 
      end
    end
  end

=begin
  


SavingsEntry.where{ 
  (confirmed_at.eq nil) &
  (savings_status.eq SAVINGS_STATUS[:membership] ) 
        }.count


def get_balance( end_date) 
  total_addition = SavingsEntry.where(
      :savings_status => SAVINGS_STATUS[:membership],
      :direction => FUND_TRANSFER_DIRECTION[:incoming]
  ).where{
    (confirmed_at.not_eq nil) & 
    (confirmed_at.lte end_date) 
  }.sum("amount")

  total_deduction = SavingsEntry.where(
      :savings_status => SAVINGS_STATUS[:membership],
      :direction => FUND_TRANSFER_DIRECTION[:outgoing]
  ).where{
    (confirmed_at.not_eq nil) & 
    (confirmed_at.lte end_date) 
  }.sum("amount")

  net = total_addition - total_deduction
  return net 
end

end_date = DateTime.new(2013,5,5,0,0,0).in_time_zone "Jakarta"
end_date_1 = end_date.end_of_year.utc


end_date = DateTime.new(2014,5,5,0,0,0).in_time_zone "Jakarta"
end_date_2 = end_date.end_of_year.utc

balance_1 = get_balance( end_date_1 )

balance_2 = get_balance( end_date_2 )

puts "2013: #{balance_1.to_s}"
puts "2014: #{balance_2.to_s}"

movement_2 = get_movement( end_date_2 )

date_2014 = DateTime.new(2014,5,5,0,0,0).in_time_zone "Jakarta"

def get_movement( date_2014)

  starting_datetime = date.utc 
  ending_datetime = date.utc 

  total_addition = SavingsEntry.where(
      :savings_status => SAVINGS_STATUS[:membership],
      :direction => FUND_TRANSFER_DIRECTION[:incoming]
  ).where{
      (confirmed_at.not_eq nil) & 
      
      (confirmed_at.lte ending ) & 
      (confirmed_at.gt starting)

  }.sum("amount")

  total_deduction = SavingsEntry.where(
      :savings_status => SAVINGS_STATUS[:membership],
      :direction => FUND_TRANSFER_DIRECTION[:outgoing]
  ).where{
      (confirmed_at.not_eq nil) & 
      (confirmed_at.lte ending ) & 
      (confirmed_at.gt starting)

  }.sum("amount")

  net = total_addition - total_deduction
  return net 
  

end


  

=end
  
=begin
  # Independent savings, 
=end
  def self.create_object( params ) 
    new_object = self.new 
    
    if params[:savings_status].nil?
      new_object.errors.add(:generic_errors, "Harus ada savings status")
      return new_object 
    end
    
    if not [
              SAVINGS_STATUS[:savings_account],
              SAVINGS_STATUS[:membership],
              SAVINGS_STATUS[:locked] ].include?( params[:savings_status].to_i ) 
      new_object.errors.add(:generic_errors , "Savings Status must be present")
      return new_object
    end
    
    
    # puts "Inside self.create_object\n"
    
    
    new_object.savings_source_id      = nil  
    new_object.savings_source_type    = nil 
    new_object.amount                 = BigDecimal(params[:amount] || '0')
    new_object.savings_status         = params[:savings_status]
    new_object.direction              = params[:direction]
    new_object.financial_product_id   = nil 
    new_object.financial_product_type = nil
    new_object.member_id              = params[:member_id]
    new_object.save 
     
    return new_object
  end
  
  def  update_object( params ) 
    
    if params[:savings_status].nil?
      self.errors.add(:generic_errors, "Harus ada savings status")
      return self 
    end
    
    if not [
              SAVINGS_STATUS[:savings_account],
              SAVINGS_STATUS[:membership],
              SAVINGS_STATUS[:locked] ].include?( params[:savings_status].to_i ) 
      self.errors.add(:generic_errors , "Savings Status must be present")
      return self
    end
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, 'Sudah dikonfirmasi. Silakan unconfirm')
      return self 
    end
    
    
    
    self.savings_source_id      = nil  
    self.savings_source_type    = nil 
    self.amount                 = BigDecimal(params[:amount] || '0')
    self.savings_status         = params[:savings_status]
    self.direction              = params[:direction]
    self.financial_product_id   = nil 
    self.financial_product_type = nil
    self.member_id              = params[:member_id]
    
    self.save
  end
  
  
=begin
  Variant permanent Savings: membership + locked
=end
  def self.create_variant_object( params, savings_status_case ) 
    
    
    
    # puts "Inside self.create_object\n"
    new_object = self.new 
    if not savings_status_case.present?
      new_object.errors.add(:generic_errors , "Savings Status must be present")
      return new_object
    end
    
    savings_status_case = savings_status_case.to_i 
    
    if not [
              SAVINGS_STATUS[:membership],
              SAVINGS_STATUS[:locked] ].include?( savings_status_case ) 
      new_object.errors.add(:generic_errors , "Savings Status must be present")
      return new_object
    end
    
    new_object.savings_source_id      = nil  
    new_object.savings_source_type    = nil 
    new_object.amount                 = BigDecimal(params[:amount] || '0')
    new_object.savings_status         = savings_status_case
    new_object.direction              = params[:direction]
    new_object.financial_product_id   = nil 
    new_object.financial_product_type = nil
    new_object.member_id              = params[:member_id]
    new_object.save 
     
    return new_object
  end
  
  def  update_variant_object( params, savings_status_case ) 
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, 'Sudah dikonfirmasi. Silakan unconfirm')
      return self 
    end
    
    if not savings_status_case.present?
      new_object.errors.add(:generic_errors , "Savings Status must be present")
      return new_object
    end
    
    savings_status_case = savings_status_case.to_i 
    
    if not [
              SAVINGS_STATUS[:membership],
              SAVINGS_STATUS[:locked] ].include?( savings_status_case ) 
      new_object.errors.add(:generic_errors , "Savings Status must be present")
      return new_object
    end
    
    self.savings_source_id      = nil  
    self.savings_source_type    = nil 
    self.amount                 = BigDecimal(params[:amount] || '0')
    self.savings_status         = savings_status_case
    self.direction              = params[:direction]
    self.financial_product_id   = nil 
    self.financial_product_type = nil
    self.member_id              = params[:member_id]
    
    self.save
  end
  
  
=begin
  Admin edit. Ensure admin role 
=end

  def self.create_adustment_variant_object( params, savings_status_case ) 
    
    
    
    # puts "Inside self.create_object\n"
    new_object = self.new 
    if not savings_status_case.present?
      new_object.errors.add(:generic_errors , "Savings Status must be present")
      return new_object
    end
    
    savings_status_case = savings_status_case.to_i 
    
    if not [  
              SAVINGS_STATUS[:savings_account],
              SAVINGS_STATUS[:membership],
              SAVINGS_STATUS[:locked] ].include?( savings_status_case ) 
      new_object.errors.add(:generic_errors , "Savings Status must be present")
      return new_object
    end
    
    new_object.savings_source_id      = nil  
    new_object.savings_source_type    = nil 
    new_object.amount                 = BigDecimal(params[:amount] || '0')
    new_object.savings_status         = savings_status_case
    new_object.direction              = params[:direction]
    new_object.financial_product_id   = nil 
    new_object.financial_product_type = nil
    new_object.member_id              = params[:member_id]
    new_object.is_adjustment = true 
    new_object.save 
     
    return new_object
  end
  
  def  update_adjustment_variant_object( params, savings_status_case ) 
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, 'Sudah dikonfirmasi. Silakan unconfirm')
      return self 
    end
    
    if not savings_status_case.present?
      new_object.errors.add(:generic_errors , "Savings Status must be present")
      return new_object
    end
    
    savings_status_case = savings_status_case.to_i 
    
    if not [
              SAVINGS_STATUS[:savings_account],
              SAVINGS_STATUS[:membership],
              SAVINGS_STATUS[:locked] ].include?( savings_status_case ) 
      new_object.errors.add(:generic_errors , "Savings Status must be present")
      return new_object
    end
    
    self.savings_source_id      = nil  
    self.savings_source_type    = nil 
    self.amount                 = BigDecimal(params[:amount] || '0')
    self.savings_status         = savings_status_case
    self.direction              = params[:direction]
    self.financial_product_id   = nil 
    self.financial_product_type = nil
    self.member_id              = params[:member_id]
    
    self.save
  end
  


=begin
  The rest 
=end
  
  def delete_object
    if self.is_confirmed?
      self.errors.add(:generic_errors, 'Sudah dikonfirmasi. Silakan unconfirm')
      return self
    end
    
    self.destroy 
  end
  
  
  def confirm(params)
    if self.is_confirmed?
      self.errors.add(:generic_errors, 'Sudah dikonfirmasi.')
      return self
    end
    
    # validate that the final amount will never be negative 
    
    if params[:confirmed_at].nil? or not params[:confirmed_at].is_a?(DateTime)
      self.errors.add(:confirmed_at, "Harus ada tanggal konfirmasi pembayaran")
      return self 
    end
    
    self.valid_withdrawal_amount
    
    if self.errors.size != 0 
      self.errors.add(:generic_errors, "Tidak cukup untuk melakukan penarikan: #{member.total_savings_account}")
      return self 
    end
    
    
    self.is_confirmed = true
    self.confirmed_at = params[:confirmed_at]
    if self.save
      multiplier = 1 if self.direction == FUND_TRANSFER_DIRECTION[:incoming]
      multiplier = -1 if self.direction == FUND_TRANSFER_DIRECTION[:outgoing]
      
     
     # voluntary savings account 
      if self.savings_status == SAVINGS_STATUS[:savings_account]
        member.update_total_savings_account( multiplier  *self.amount )
        AccountingService::IndependentSavings.post_savings_account(self, multiplier  )
        
    # one off savings so that the member is elligible for borrowing $$ from KKI
      elsif  self.savings_status == SAVINGS_STATUS[:membership]
        member.update_total_membership_savings_account( multiplier  *self.amount )
        AccountingService::IndependentSavings.post_membership_savings_account(self, multiplier   )
    # kept $$ to sustain group loan membership
      elsif self.savings_status == SAVINGS_STATUS[:locked]
        member.update_total_locked_savings_account( multiplier  *self.amount )
        AccountingService::IndependentSavings.post_locked_savings_account(self, multiplier  )
      end
      
      
      
    end
  end
  
   
  def unconfirm
    
    if not self.is_confirmed?
      self.errors.add(:generic_errors, 'Belum dikonfirmasi.')
      return self
    end

    if self.direction ==  FUND_TRANSFER_DIRECTION[:incoming] and SAVINGS_STATUS[:savings_account]
      if member.total_savings_account - self.amount < BigDecimal("0")
        self.errors.add(:generic_errors, "Nilai akhir akan minus")
        return self
      end
    end

    if self.direction ==  FUND_TRANSFER_DIRECTION[:incoming] and SAVINGS_STATUS[:membership]
      if member.total_membership_savings - self.amount < BigDecimal("0")
        self.errors.add(:generic_errors, "Nilai akhir akan minus")
        return self
      end
    end

    if self.direction ==  FUND_TRANSFER_DIRECTION[:incoming] and SAVINGS_STATUS[:locked]
      if member.total_locked_savings_account - self.amount < BigDecimal("0")
        self.errors.add(:generic_errors, "Nilai akhir akan minus")
        return self
      end
    end


    self.is_confirmed = false
    self.confirmed_at = nil 
    
    
    if self.save 
      member = self.member 
      multiplier = -1 
      multiplier = 1 if self.direction ==  FUND_TRANSFER_DIRECTION[:outgoing]


      if self.savings_status == SAVINGS_STATUS[:savings_account]
        member.update_total_savings_account( multiplier  *self.amount )
      elsif  self.savings_status == SAVINGS_STATUS[:membership]
        member.update_total_membership_savings_account( multiplier  *self.amount )
      elsif self.savings_status == SAVINGS_STATUS[:locked]
        member.update_total_locked_savings_account( multiplier  *self.amount )
      end


      # member.update_total_savings_account( multiplier  *self.amount )
      AccountingService::IndependentSavings.cancel_journal_posting( self )
    end
    
    
  end
  
  
=begin
  GROUP LOAN related savings 
=end
  def self.create_group_loan_disbursement_initial_compulsory_savings( savings_source )
    group_loan_membership = savings_source.group_loan_membership
    member = group_loan_membership.member 
    
    new_object = self.create :savings_source_id => savings_source.id,
                        :savings_source_type => savings_source.class.to_s,
                        :amount => savings_source.group_loan_membership.group_loan_product.initial_savings ,
                        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
                        :direction => FUND_TRANSFER_DIRECTION[:incoming],
                        :financial_product_id => savings_source.group_loan_membership.group_loan_id ,
                        :financial_product_type => savings_source.group_loan_membership.group_loan.class.to_s,
                        :member_id => member.id ,
                        :is_confirmed => true ,
                        :confirmed_at => savings_source.disbursed_at 
                        
    group_loan_membership.update_total_compulsory_savings(new_object.amount)
  end
  
  def self.create_weekly_payment_compulsory_savings( savings_source )
    # puts "Gonna create savings_entry"
    group_loan_membership = savings_source.group_loan_membership
    member = group_loan_membership.member 
    
    new_object = self.create :savings_source_id => savings_source.id,
                        :savings_source_type => savings_source.class.to_s,
                        :amount => savings_source.group_loan_membership.group_loan_product.compulsory_savings ,
                        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
                        :direction => FUND_TRANSFER_DIRECTION[:incoming],
                        :financial_product_id => savings_source.group_loan_id ,
                        :financial_product_type => savings_source.group_loan.class.to_s,
                        :member_id => member.id ,
                        :is_confirmed => true, 
                        :confirmed_at => savings_source.group_loan_weekly_collection.confirmed_at 
                        
    # puts "The amount: #{new_object.amount}"
    group_loan_membership.update_total_compulsory_savings( new_object.amount)
  end
  
  def self.create_group_loan_premature_clearance_compulsory_savings_addition( savings_source , compulsory_savings_amount)
    # puts "Gonna create savings_entry"
    group_loan_membership = savings_source.group_loan_membership
    member = group_loan_membership.member 
    
    new_object = self.create :savings_source_id => savings_source.id,
                        :savings_source_type => savings_source.class.to_s,
                        :amount => compulsory_savings_amount,
                        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
                        :direction => FUND_TRANSFER_DIRECTION[:incoming],
                        :financial_product_id => savings_source.group_loan_id ,
                        :financial_product_type => savings_source.group_loan.class.to_s,
                        :member_id => member.id ,
                        :is_confirmed => true, 
                        :confirmed_at => savings_source.group_loan_weekly_collection.confirmed_at 
                        
    # puts "The amount: #{new_object.amount}"
    group_loan_membership.update_total_compulsory_savings( new_object.amount)
  end
  
  
  def self.create_group_loan_closing_compulsory_savings_deduction_bad_debt_allowance( glm , amount )
    # puts "Gonna create savings_entry"
    group_loan_membership = glm
    member = group_loan_membership.member 
    group_loan = group_loan_membership.group_loan
    savings_source = group_loan
    
    new_object = self.create :savings_source_id => savings_source.id,
                        :savings_source_type => savings_source.class.to_s,
                        :amount => amount ,
                        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
                        :direction => FUND_TRANSFER_DIRECTION[:outgoing],
                        :financial_product_id => savings_source.id ,
                        :financial_product_type => savings_source.class.to_s,
                        :member_id => member.id ,
                        :is_confirmed => true, 
                        :confirmed_at => savings_source.closed_at,
                        :message => "Bad debt allowance on GroupLoan Close: Group #{group_loan.name}, #{group_loan.group_number}"

    group_loan_membership.update_total_compulsory_savings( -1 * amount )
  
  end
  
  def self.create_group_loan_closing_compulsory_savings_deduction_interest_revenue( glm , amount )
    # puts "Gonna create savings_entry"
    group_loan_membership = glm
    member = group_loan_membership.member 
    group_loan = group_loan_membership.group_loan
    savings_source = group_loan
    
    new_object = self.create :savings_source_id => savings_source.id,
                        :savings_source_type => savings_source.class.to_s,
                        :amount => amount ,
                        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
                        :direction => FUND_TRANSFER_DIRECTION[:outgoing],
                        :financial_product_id => savings_source.id ,
                        :financial_product_type => savings_source.class.to_s,
                        :member_id => member.id ,
                        :is_confirmed => true, 
                        :confirmed_at => savings_source.closed_at,
                        :message => "Interest Revenue on GroupLoan Close: Group #{group_loan.name}, #{group_loan.group_number}"
          
    group_loan_membership.update_total_compulsory_savings( -1 * amount )
  end
  
  def self.create_group_loan_closing_compulsory_savings_clearance( glm )
    # puts "Gonna create savings_entry"
    group_loan_membership = glm
    member = group_loan_membership.member 
    group_loan = group_loan_membership.group_loan
    savings_source = group_loan
    
    new_object = self.create :savings_source_id => savings_source.id,
                        :savings_source_type => savings_source.class.to_s,
                        :amount => group_loan_membership.total_compulsory_savings ,
                        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
                        :direction => FUND_TRANSFER_DIRECTION[:outgoing],
                        :financial_product_id => savings_source.id ,
                        :financial_product_type => savings_source.class.to_s,
                        :member_id => member.id ,
                        :is_confirmed => true, 
                        :confirmed_at => savings_source.closed_at
  end
  
  
  
  def self.port_group_loan_membership_compulsory_savings( group_loan, glm )
    # puts "Gonna create savings_entry"
    group_loan_membership = glm
    member = group_loan_membership.member 
    savings_source = group_loan
    
    new_object = self.create :savings_source_id => savings_source.id,
                        :savings_source_type => savings_source.class.to_s,
                        :amount => group_loan_membership.total_compulsory_savings ,
                        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
                        :direction => FUND_TRANSFER_DIRECTION[:outgoing],
                        :financial_product_id => savings_source.id ,
                        :financial_product_type => savings_source.class.to_s,
                        :member_id => member.id ,
                        :is_confirmed => true, 
                        :confirmed_at => savings_source.closed_at
  
    group_loan_membership.update_total_compulsory_savings( -1 * group_loan_membership.total_compulsory_savings )
                       
                       # last info.. don't deduct the compulsory savings info
    # group_loan_membership.update_total_compulsory_savings( -1 * new_object.amount)
  end
  

  def create_contra_and_confirm_for_group_loan_weekly_collection_voluntary_savings(savings_source)
    puts "5585444 savings_entry.create_contra_and_confirm"
    last_transaction_data = TransactionData.where(
      :transaction_source_id => savings_source.id , 
      :transaction_source_type => savings_source.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection_voluntary_savings],
      :is_contra_transaction => false
    ).order("id DESC").first 
    
    puts "last_transaction_data : #{last_transaction_data}"
    
    group_loan_weekly_savings_entry = savings_source
    group_loan_membership = savings_source.group_loan_membership
    last_transaction_data.create_contra_and_confirm if not  last_transaction_data.nil?

    member = group_loan_membership.member 
    multiplier = 1 
    multiplier = -1 if savings_source.direction == FUND_TRANSFER_DIRECTION[:incoming]
    member.update_total_savings_account( multiplier * savings_source.amount)

    self.destroy 
  end


  
  def self.create_weekly_collection_voluntary_savings( savings_source )
    # puts "Gonna create savings_entry"
    group_loan_weekly_savings_entry = savings_source
    group_loan_membership = savings_source.group_loan_membership
    member = group_loan_membership.member 
    
    new_object = self.create :savings_source_id => savings_source.id,
                        :savings_source_type => savings_source.class.to_s,
                        :amount => savings_source.amount,
                        :savings_status => SAVINGS_STATUS[:savings_account],
                        :direction => FUND_TRANSFER_DIRECTION[:incoming],
                        :financial_product_id => group_loan_membership.group_loan_id,
                        :financial_product_type => group_loan_membership.group_loan.class.to_s,
                        :member_id => member.id ,
                        :is_confirmed => true, 
                        :confirmed_at => savings_source.group_loan_weekly_collection.confirmed_at 
                        
    # puts "The amount: #{new_object.amount}"
    multiplier = 1 
    multiplier = -1 if savings_source.direction == FUND_TRANSFER_DIRECTION[:outgoing]
    member.update_total_savings_account( multiplier * new_object.amount)
    
    
    # do accounting posting 
    group_loan = group_loan_membership.group_loan
    group_loan_weekly_collection = savings_source.group_loan_weekly_collection
    AccountingService::WeeklyCollectionVoluntarySavings.create_journal_posting(
      group_loan,
      group_loan_weekly_collection,
      savings_source
    )
    
    
  end
   
   

  def self.migrate_generated_data_by_weekly_collection
    SavingsEntry.where{
      (is_confirmed.eq true )  & 
      (confirmed_at.eq nil )  & 
      (savings_source_type.eq  "GroupLoanWeeklyCollectionVoluntarySavingsEntry")
    }.find_each do |se|
      
      grlwc_vse = GroupLoanWeeklyCollectionVoluntarySavingsEntry.find_by_id( se.savings_source_id )

      glwc = GroupLoanWeeklyCollection.find_by_id( grlwc_vse.group_loan_weekly_collection_id )
      se.confirmed_at = glwc.confirmed_at 
      se.save 
    end
  end
 
  
  def self.create_group_loan_compulsory_savings_withdrawal( savings_source, amount ) 
    # puts "The savings_source: #{savings_source.inspect}"
    group_loan_membership = savings_source.group_loan_membership
    member = group_loan_membership.member
    
    confirmation_time = nil 
    
    if savings_source.class == GroupLoanPrematureClearancePayment
      confirmation_time = savings_source.group_loan_weekly_collection.confirmed_at 
    elsif savings_source.class == DeceasedClearance
      confirmation_time = savings_source.member.deceased_at 
    end
    
    new_object = self.create :savings_source_id => savings_source.id,
                        :savings_source_type => savings_source.class.to_s,
                        :amount => amount  ,
                        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
                        :direction => FUND_TRANSFER_DIRECTION[:outgoing],
                        :financial_product_id => savings_source.group_loan_id ,
                        :financial_product_type => savings_source.group_loan.class.to_s,
                        :member_id => member.id,
                        :is_confirmed => true, 
                        :confirmed_at => confirmation_time
  
    group_loan_membership.update_total_compulsory_savings(-1* new_object.amount)
  end
  


  def self.create_savings_account_group_loan_premature_clearance_addition( savings_source, amount ) 
    member = savings_source.member

    new_object = self.create :savings_source_id => savings_source.id,
      :savings_source_type => savings_source.class.to_s,
      :amount => amount  ,
      :savings_status => SAVINGS_STATUS[:savings_account],
      :direction => FUND_TRANSFER_DIRECTION[:incoming],
      :financial_product_id =>  savings_source.group_loan.id  ,
      :financial_product_type => savings_source.group_loan.class.to_s ,
      :member_id => member.id,
      :is_confirmed => true, 
      :confirmed_at => savings_source.group_loan_weekly_collection.confirmed_at

    member.update_total_savings_account( new_object.amount)
  end
  
  def self.create_savings_account_group_loan_deceased_addition( savings_source, amount ) 
    # puts "creating savings_account addition because of deceased member"
    member = savings_source.member

    new_object = self.create :savings_source_id => savings_source.id,
      :savings_source_type => savings_source.class.to_s,
      :amount => amount  ,
      :savings_status => SAVINGS_STATUS[:savings_account],
      :direction => FUND_TRANSFER_DIRECTION[:incoming],
      :financial_product_id =>  savings_source.group_loan.id  ,
      :financial_product_type => savings_source.group_loan.class.to_s ,
      :member_id => member.id,
      :is_confirmed => true ,
      :confirmed_at => savings_source.member.deceased_at 

    member.update_total_savings_account( new_object.amount)
  end
  
  
  
  
  def internal_delete_object
    if self.financial_product_id.nil? 
      self.errors.add(:generic_errors, "Can only be used to cancel automated transaction")
      return self 
    end
    
    member = self.member 
    multiplier = -1 
    multiplier = 1 if self.direction ==  FUND_TRANSFER_DIRECTION[:outgoing]
    
    if self.savings_status == SAVINGS_STATUS[:savings_account]
      
      member.update_total_savings_account( multiplier  *self.amount )
    elsif self.savings_status == SAVINGS_STATUS[:group_loan_compulsory_savings]
      glm = savings_source.group_loan_membership
      glm.update_total_compulsory_savings( multiplier * self.amount)
    end
    
    self.destroy 
  end
  
   
    
    
    
  
=begin
  Savings Account related savings : savings withdrawal and savings addition and interest (4% annual), given monthly 
=end

  
  def create_contra_and_confirm(transaction_code)
    puts "5585444 savings_entry.create_contra_and_confirm"
    last_transaction_data = TransactionData.where(
      :transaction_source_id => self.id , 
      :transaction_source_type => self.class.to_s ,
      :code => transaction_code,
      :is_contra_transaction => false
    ).order("id DESC").first 
    
    puts "last_transaction_data : #{last_transaction_data}"
    

    last_transaction_data.create_contra_and_confirm if not  last_transaction_data.nil?
  end


def self.savings_ratio_in_month( target_datetime )
  start_datetime = target_datetime.beginning_of_month
  end_datetime = target_datetime.end_of_month 

  total_counter_weekly_collection = SavingsEntry.where{
            (is_confirmed.eq true )  &   
            (savings_source_type.eq  "GroupLoanWeeklyCollectionVoluntarySavingsEntry") & 
            ( confirmed_at.gte start_datetime ) & 
            ( confirmed_at.lt end_datetime )
          }.count 

  total_counter_independent = SavingsEntry.where{
            (savings_status.eq  SAVINGS_STATUS[:savings_account]) & 
            ( is_confirmed.eq true ) & 
            ( confirmed_at.gte start_datetime ) & 
            ( confirmed_at.lt end_datetime ) & 
            ( savings_source_type.eq nil )
          }.count 

  return [total_counter_weekly_collection , total_counter_independent]

end
  

                      
end
