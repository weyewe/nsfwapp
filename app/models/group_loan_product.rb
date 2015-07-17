class GroupLoanProduct < ActiveRecord::Base
  # attr_accessible :title, :body
  # belongs_to :office 
  
  validates_presence_of  :total_weeks, 
                        :principal,
                        :interest,
                        :compulsory_savings,
                        :admin_fee, 
                        :name 
        
   
  has_many :group_loan_memberships 
  
  
  validate :total_weeks_must_not_be_zero
  validate :no_negative_payment_amount 
  validate :allow_update_if_no_subcriptions
  
  def total_weeks_must_not_be_zero
    return  if not all_fields_present? 
    if  total_weeks <=  0 
      errors.add(:total_weeks, "Jumlah minggu cicilan harus lebih besar dari 0")
    end
  end
  
  def no_negative_payment_amount
    return  if not all_fields_present? 
    
    zero_amount = BigDecimal('0')
    
    if principal <= zero_amount
      errors.add(:principal, "Cicilan Principal  tidak boleh negative")
    end
    
    if interest <= zero_amount
      errors.add(:interest, "Bunga tidak boleh negative")
    end
    
    if compulsory_savings <= zero_amount
      errors.add(:compulsory_savings, "Tabungan wajib tidak boleh negative")
    end
    
    if admin_fee <= zero_amount
      errors.add(:admin_fee, "Biaya administrasi tidak boleh negative")
    end
    
    
  end
  
  def allow_update_if_no_subcriptions
    return  if not all_fields_present? 
    
    if self.persisted? and self.group_loan_memberships.count != 0 
      self.errors.add(:generic_errors, "Sudah ada peminjaman dengan menggunakan product ini")
    end
  end
  
  def all_fields_present?
    name.present? and 
    total_weeks.present? and 
    principal.present?              and   
    interest.present?               and   
    compulsory_savings.present?            and   
    admin_fee.present?           
  end
  
  
  
  def self.create_object(   params) 
    new_object                 = self.new 
    new_object.name            = params[:name]
    new_object.total_weeks     = params[:total_weeks]
    new_object.principal       = BigDecimal( params[:principal] || '0')
    new_object.interest        = BigDecimal( params[:interest        ] || '0')
    new_object.compulsory_savings     = BigDecimal( params[:compulsory_savings     ] || '0')
    new_object.admin_fee       = BigDecimal( params[:admin_fee       ] || '0')
    new_object.initial_savings = BigDecimal( params[:initial_savings ] || '0')
    
    new_object.save 
    return new_object
  end
  
  def update_object( params ) 
    
    self.name            = params[:name]
    self.total_weeks     = params[:total_weeks]
    self.principal       = BigDecimal( params[:principal] || '0')
    self.interest        = BigDecimal( params[:interest        ] || '0')
    self.compulsory_savings     = BigDecimal( params[:compulsory_savings     ] || '0')
    self.admin_fee       = BigDecimal( params[:admin_fee       ] || '0')
    self.initial_savings = BigDecimal( params[:initial_savings ] || '0')
    
    self.save 
    return self
  end
  
  def delete_object
    allow_update_if_no_subcriptions # validation 
    # return if self.errors.size != 0 
    
    
    if self.group_loan_memberships.count != 0 
      self.errors.add(:generic_errors, "Masih ada anggota pinjaman group yang menggunakan group loan product ini")
      return self
    end
    
    self.destroy 
  end
  
  def disbursed_principal
    principal * total_weeks 
  end
  
  
  def weekly_payment_amount
    principal + interest  + compulsory_savings
  end
  
  def actual_amount_to_be_disbursed
    principal*total_weeks 
  end
  
end

=begin
glp_id_list = []
GroupLoanProduct.all.each do |glp|
  first_amount = BigDecimal("1200000")
  second_amount = BigDecimal("2200000")
  if glp.disbursed_principal == first_amount or glp.disbursed_principal == second_amount
    glp_id_list << glp.id 
  end
end

affected_glm_list = [] 
GroupLoanMembership.where(:group_loan_product_id => glp_id_list).each do |glm|
  affected_glm_list << glm.id 
end

result = [] 
GroupLoanMembership.joins(:group_loan, :member).where(:id => affected_glm_list ).each do |glm|
  array = []
  array << glm.group_loan.name 
  array << glm.member.name 
  array << glm.member.id_number 
  
  if not glm.group_loan.disbursed_at.nil? 
    array << glm.group_loan.disbursed_at.in_time_zone("Jakarta").to_s
  else
    array <<  "NA"
  end
  
  array << glm.group_loan_product.interest.to_i
  
  
  result << array 
end


=end
