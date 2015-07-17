class GroupLoanMembership < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :member 
  belongs_to :group_loan 
   
  belongs_to :group_loan_product 
  has_many :group_loan_weekly_payments
  
  has_one :group_loan_disbursement  #checked  
  has_one :group_loan_port_compulsory_savings 
  has_one :group_loan_run_away_receivable
  has_many :group_loan_weekly_uncollectibles
  
  # has_one :group_loan_default_payment 
  has_one :group_loan_premature_clearance_payment 

  has_many :group_loan_weekly_collection_voluntary_savings_entries
  
    
  
  validates_presence_of :group_loan_id, :member_id , :group_loan_product_id 
  
  validate :no_active_membership_of_another_group_loan
  validate :no_deceased_or_run_away_member
  validate :valid_member_id
  validate :valid_group_loan_product_id


  def weekly_collection_attendance( weekly_collection )
    GroupLoanWeeklyCollectionAttendance.where(
        :group_loan_membership_id => self.id , 
        :group_loan_weekly_collection_id => weekly_collection.id 
      ).first 
  end

  def weekly_collection_voluntary_savings_entry( weekly_collection ) 
    GroupLoanWeeklyCollectionVoluntarySavingsEntry.where(
        :group_loan_membership_id => self.id , 
        :group_loan_weekly_collection_id => weekly_collection.id 
      ).first
  end
  
  def valid_member_id
    return if member_id.nil? 
    assigned_member =  Member.find_by_id member_id
    
    if assigned_member.nil?
      self.errors.add(:member_id , "Harus ada dan valid")
      return self
    end
  end
  
  def valid_group_loan_product_id
    return if group_loan_product_id.nil? 
    assigned_glp =  GroupLoanProduct.find_by_id group_loan_product_id
    
    if assigned_glp.nil?
      self.errors.add(:group_loan_product_id , "Harus ada dan valid")
      return self
    end
  end
  
  def no_active_membership_of_another_group_loan
    return if self.persisted? or not self.member_id.present? 
    
    if GroupLoanMembership.where(:is_active => true, :member_id => self.member_id ).count != 0
      self.errors.add(:member_id , "Sudah ada pinjaman di group lainnya")
    end
  end
  
  def no_deceased_or_run_away_member
    return if self.persisted? or not self.member_id.present?
    
    if member.is_run_away? 
      self.errors.add(:generic_errors, "Member #{member.name} kabur")
      return self 
    end
    
    if member.is_deceased?
      self.errors.add(:generic_errors, "Member #{member.name} meninggal")
      return self 
    end
  end
  
  def ensure_group_loan_is_not_started
    return if not self.group_loan_id.present?
    
    if self.group_loan.is_started? 
      self.errors.add(:generic_errors, "Group Loan sudah dimulai")
      return self 
    end
  end
  
  
 
  
  def self.create_object( params ) 
    new_object = self.new 
    new_object.group_loan_id      = params[:group_loan_id] 
    new_object.member_id          = params[:member_id]
    new_object.group_loan_product_id          = params[:group_loan_product_id]
    new_object.save
    
    return new_object 
  end
  
  def update_object( params ) 
    return nil if self.group_loan.is_started? 
    self.member_id = params[:member_id]
    self.group_loan_product_id          = params[:group_loan_product_id]
    self.save
  end
  
  def delete_object
    if self.group_loan.is_started? 
      self.errors.add(:generic_errors, "Group Loan sudah dimulai. tidak bisa delete")
      return self 
    end
    
    self.destroy 
  end 
     
  # def port_compulsory_savings_to_voluntary_savings
  #   GroupLoanPortCompulsorySavings.create :group_loan_membership_id => self.id 
  #   
  #   self.update_total_compulsory_savings
  #   self.update_total_voluntary_savings
  # end
  #   
  
  
  def update_total_compulsory_savings(amount)
    # puts "Gonna update total compulsory savings: #{amount}"
    self.total_compulsory_savings += amount 
    self.save 
    
    # puts "The total_compulsory_savings: #{self.total_compulsory_savings}"
    # puts "is_valid: #{self.valid?}"
    # 
    # self.errors.messages.each do |msg|
    #   puts "The msg: #{msg}"
    # end
  end
  
  # def update_personal_bad_debt_allowance(amount)
  #   self.personal_bad_debt_allowance += amount 
  #   self.save 
  # end
  # 
  # def update_potential_loss_interest_revenue( amount ) 
  #   self.potential_loss_interest_revenue += amount 
  #   self.save
  # end
   
  
=begin
  Corner Case : Deceased member 
=end

  def remaining_deceased_principal_payment
    
      remaining_number_of_weeks = self.group_loan.loan_duration - 
                                  self.deactivation_week_number + 
                                  1 # for the week where deceased is declared
                                  
      return remaining_number_of_weeks * self.group_loan_product.principal 
    
  end
  
=begin
  Corner Case: RunAway member
=end

  def run_away_remaining_group_loan_payment
    total_weeks = self.group_loan.number_of_collections 
    paid_weeks_count = self.group_loan_weekly_payments.count 
    
    (total_weeks - paid_weeks_count ) * group_loan_product.weekly_payment_amount
    
    # for the default payment, will be recalculated, reducing the pool of default bearer. 
  end
  
  def deactivate(params)
    if not self.group_loan.is_started?
      self.errors.add(:generic_errors, "GroupLoan belum dimulai. Silakan delete")
      return self 
    end
    
    if self.group_loan.is_loan_disbursed?
      self.errors.add(:generic_errors, "Pinjaman sudah dicairkan")
      return self 
    end
    
    if not params[:deactivation_case].present? 
      self.errors.add(:deactivation_case, "Harus memilih kondisi non-aktif")
      return self 
    end
    
    
    if not [
        GROUP_LOAN_DEACTIVATION_CASE[:financial_education_absent],
        GROUP_LOAN_DEACTIVATION_CASE[:loan_disbursement_absent]
      ].include?(params[:deactivation_case].to_i)
      self.errors.add(:deactivation_case, "Harus memilih kondisi non-aktif")
      return self
    end
    
    
    self.is_active = false 
    self.deactivation_case = params[:deactivation_case].to_i
    self.save 
  end
  
  def deactivation_case_name
    # GROUP_LOAN_DEACTIVATION_CASE = {
    #   :financial_education_absent => 1, 
    #   :loan_disbursement_absent => 2 ,
    #   :finished_group_loan => 3 ,
    # 
    # 
    #   :deceased => 10,
    #   :run_away => 11,
    #   :premature_clearance => 12 
    # }
    
    return "Financial Education Absent" if self.deactivation_case == GROUP_LOAN_DEACTIVATION_CASE[:financial_education_absent]
    return "Loan Disbursement Absent" if self.deactivation_case == GROUP_LOAN_DEACTIVATION_CASE[:loan_disbursement_absent]
    return "Group Loan Selesai" if self.deactivation_case == GROUP_LOAN_DEACTIVATION_CASE[:finished_group_loan]
    
    return "Meninggal" if self.deactivation_case == GROUP_LOAN_DEACTIVATION_CASE[:deceased]
    return "Kabur" if self.deactivation_case == GROUP_LOAN_DEACTIVATION_CASE[:run_away]
    return "Premature Clearance" if self.deactivation_case == GROUP_LOAN_DEACTIVATION_CASE[:premature_clearance]
    

  end
  
end
