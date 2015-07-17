class GroupLoanWeeklyCollectionVoluntarySavingsEntry < ActiveRecord::Base
  belongs_to :group_loan_membership
  belongs_to :group_loan_weekly_collection
  
  validates_presence_of :amount, :group_loan_membership_id, :group_loan_weekly_collection_id
  
  validate :valid_amount
  validate :valid_group_loan_membership_id
  validate :valid_group_loan_weekly_collection_id
  validate :valid_glm_group_loan_weekly_collection_id 
  validate :group_loan_weekly_collection_not_collected
  validate :group_loan_membership_is_still_active
  validate :no_double_group_loan_membership
  
  validate :valid_group_loan_membership_id

  validate :valid_direction

  def valid_direction  

    if not [
        FUND_TRANSFER_DIRECTION[:incoming],
        FUND_TRANSFER_DIRECTION[:outgoing]
      ].include?(self.direction)
      self.errors.add(:direction, "Harus memilih tipe transaksi: penambahan atau pengurangan")
      return self 
    end
  end

  
  def valid_group_loan_membership_id
    return if group_loan_membership_id.nil? 
    assigned_glm =  GroupLoanMembership.find_by_id group_loan_membership_id
    
    if assigned_glm.nil?
      self.errors.add(:group_loan_membership_id , "Harus ada dan valid")
      return self
    end
  end
  
  
  
  def valid_amount
    return if not self.amount.present?

    
    if self.amount <= BigDecimal('0')
      self.errors.add(:amount, "Harus lebih besar daripada 0")
      return self 
    end

    if self.direction == FUND_TRANSFER_DIRECTION[:outgoing]
      if group_loan_membership.member.total_savings_account - self.amount < BigDecimal("0")
        self.errors.add(:amount, "Tidak cukup dana")
        return self 
      end
    end

  end
  
  def valid_group_loan_membership_id 
    return if self.group_loan_membership_id.nil? 
    begin
      glm = GroupLoanMembership.find self.group_loan_membership_id
    rescue
      self.errors.add(:group_loan_membership_id, "Harus Valid")
    end
  end
  
  def valid_group_loan_weekly_collection_id
    return if self.group_loan_weekly_collection_id.nil? 
    
    begin
      glm = GroupLoanWeeklyCollection.find self.group_loan_weekly_collection_id
    rescue
      self.errors.add(:group_loan_weekly_collection_id, "Harus Valid")
    end
  end
  
  def valid_glm_group_loan_weekly_collection_id
    return if group_loan_membership_id.nil? or 
            group_loan_weekly_collection_id.nil?
            
    if group_loan_membership.group_loan_id != group_loan_weekly_collection.group_loan_id
      self.errors.add(:generic_errors, "Invalid GroupLoanMembership and GroupLoanWeeklyCollection combination")
    end
  end
  
  def group_loan_weekly_collection_not_collected
    return if group_loan_weekly_collection_id.nil?
    
    if group_loan_weekly_collection.is_collected?
      self.errors.add(:generic_errors, "Sudah terkumpul")
    end
  end
  
  def group_loan_membership_is_still_active
    return if group_loan_membership_id.nil?
    return if group_loan_weekly_collection_id.nil? 
    
    active_glm_id_list = group_loan_weekly_collection.active_group_loan_memberships.map {|x| x.id}
    if not active_glm_id_list.include?(self.group_loan_membership_id)
      self.errors.add(:generic_errors, "Member sudah tidak aktif di group ini")
    end
  end
  
  def no_double_group_loan_membership
    return if self.persisted? 
    return if group_loan_membership_id.nil?
    return if group_loan_weekly_collection_id.nil? 
    
    voluntary_savings_glm_id_list = group_loan_weekly_collection.
                                      group_loan_weekly_collection_voluntary_savings_entries.
                                      map {|x| x.group_loan_membership_id}
 
    if voluntary_savings_glm_id_list.include?( group_loan_membership_id )
      self.errors.add(:generic_errors, "Sudah ada tabungan oleh member tersebut")
      return self 
    end
    
  end
  
  def self.create_object(  params)
   
    new_object = self.new
    
    new_object.amount        = BigDecimal( params[:amount] )
    new_object.group_loan_membership_id = params[:group_loan_membership_id]
    new_object.group_loan_weekly_collection_id = params[:group_loan_weekly_collection_id]
    new_object.direction = params[:direction]
    
    new_object.save
    
    return new_object 
  end
  
  def  update_object( params ) 
    
    if self.group_loan_weekly_collection.is_collected?
      self.errors.add(:generic_errors, "Sudah terkumpul")
      return self
    end
    
    self.amount        = BigDecimal( params[:amount] )
    self.group_loan_membership_id = params[:group_loan_membership_id]
    self.group_loan_weekly_collection_id = params[:group_loan_weekly_collection_id]
    self.direction = params[:direction]
    
    self.save 
    
    return self
  end
  
  def delete_object
    if self.group_loan_weekly_collection.is_collected?
      self.errors.add(:generic_errors, "Sudah terkumpul")
      return self
    end
    
    self.destroy 
  end
  
  def confirm 
    if group_loan_weekly_collection.is_collected? # and not group_loan_weekly_collection.is_confirmed? 
      SavingsEntry.create_weekly_collection_voluntary_savings( self ) 
    else
      self.errors.add(:generic_errors, "Sudah dikonfirmasi")
      return self
    end
  end
  
  def unconfirm
    
    member = self.group_loan_membership.member 

    weekly_collection_voluntary_savings_array = SavingsEntry.where(
      :savings_source_id => self.id ,
      :savings_source_type => self.class.to_s,
      :member_id => member.id
    )
    
   

    weekly_collection_voluntary_savings_array.each do |x|
      x.create_contra_and_confirm_for_group_loan_weekly_collection_voluntary_savings( self )
    end
 
    return self 
  end
  
end

=begin
  GroupLoanWeeklyCollectionVoluntarySavingsEntry.all.each do |x|
    x.direction = FUND_TRANSFER_DIRECTION[:incoming]
    x.save
  end
=end
