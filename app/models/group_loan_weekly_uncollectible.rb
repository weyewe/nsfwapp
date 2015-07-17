class GroupLoanWeeklyUncollectible < ActiveRecord::Base
  attr_accessible :amount, :group_loan_membership_id, :group_loan_id, :group_loan_weekly_collection_id 
  
  belongs_to :group_loan_membership 
  belongs_to :group_loan
  belongs_to :group_loan_weekly_collection 
  
  
  validates_presence_of :group_loan_membership_id, :group_loan_id, :group_loan_weekly_collection_id , :clearance_case
  
  validate :uniq_weekly_collection_and_membership
  validate :use_first_uncollected_weekly_collection
  validate :no_creation_if_weekly_collection_is_confirmed
  validate :valid_clearance_case
  validate :valid_active_member 
  
 
  
  def valid_active_member
    return if not all_fields_present?
    return if not self.group_loan.is_closed?
      
    
    member = self.group_loan_membership.member
    if  not self.group_loan.is_closed? and not  self.group_loan_membership.is_active? 
      self.errors.add(:generic_errors, "Member #{member.name} tidak aktif")
      return self 
    end
  end
  
  def valid_clearance_case
    return if not all_fields_present?
    
    if not [
      UNCOLLECTIBLE_CLEARANCE_CASE[:end_of_cycle],
      UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
      ].include?(self.clearance_case)
      self.errors.add(:clearance_case, "Kasus penyelesaian pembayaran tak tertagih harus dipilih")
      return self 
    end
  end
  
  def all_fields_present?
    group_loan_weekly_collection_id.present? and 
                group_loan_id.present? and 
                group_loan_membership_id.present? and 
                clearance_case.present? 
  end
  
  def has_duplicate_entry?
    current_object=  self  
    self.duplicate_entries.count != 0  
  end
  
  def duplicate_entries
    current_object=  self  
    self.class.where(
      :group_loan_membership_id => current_object.group_loan_membership_id ,
      :group_loan_weekly_collection_id => current_object.group_loan_weekly_collection_id,
      :group_loan_id => current_object.group_loan_id
    )
 
  end
  
  def uniq_weekly_collection_and_membership
    msg = 'Sudah ada record yang sama'
    
    current_object = self 
    return if not all_fields_present? 
    


    if not current_object.persisted? and current_object.has_duplicate_entry?  
      errors.add(:group_loan_membership_id ,  msg )  
    elsif current_object.persisted? and 
          ( current_object.group_loan_membership_id_changed? or 
            current_object.group_loan_weekly_collection_id_changed?)   and
          current_object.has_duplicate_entry?   
          # if duplicate entry is itself.. no error
          # else.. some error

        if current_object.duplicate_entries.count == 1  and 
            current_object.duplicate_entries.first.id == current_object.id 
        else
          errors.add(:group_loan_membership_id , msg )  
        end 
    end       
  end
  
  def use_first_uncollected_weekly_collection
    return if not all_fields_present? 
    return if self.persisted? 
    
    if group_loan.first_uncollected_weekly_collection.id != self.group_loan_weekly_collection_id 
      
      msg = "Pengumpulan minggu #{group_loan_weekly_collection.week_number} tidak valid"
      self.errors.add(:group_loan_weekly_collection_id , msg  )
      return self 
    end
  end
  
  def no_creation_if_weekly_collection_is_confirmed
    return if not all_fields_present? 
    return if self.persisted? 
    
    if group_loan_weekly_collection.is_collected?
      self.errors.add(:group_loan_weekly_collection_id, "Sudah terkonfirmasi. Tidak bisa ditambah.")
    end
  end
  
  
  
  
  
  def update_amount 
    self.amount = self.group_loan_membership.group_loan_product.weekly_payment_amount
    self.principal = self.group_loan_membership.group_loan_product.principal
    self.save
  end
  
  def create_allowance_transaction_data_from_uncollectible
    # 1. get the principal, 
    # 2. use that amount. credit piutang, debit allowance
    member = self.group_loan_membership.member
    group_loan = self.group_loan
    group_loan_weekly_collection = self.group_loan_weekly_collection
    
    AccountingService::UncollectibleDeclaration.create_uncollectible_declaration(
      group_loan,
      group_loan_weekly_collection,
      member,
      self
    )
    
  end
  
  def create_contra_allowance_transaction_data
    AccountingService::UncollectibleDeclaration.cancel_uncollectible_declaration( self )
  end
  
  def create_allowance_in_cycle_clearance_transaction_data
    # 1. Cash ++ 1 week worth of payment
    # 2. allowance is being deducted 
    
    member = self.group_loan_membership.member
    group_loan = self.group_loan
    group_loan_weekly_collection = self.group_loan_weekly_collection
    AccountingService::UncollectibleDeclaration.create_in_cycle_clearance(group_loan,
                                group_loan_weekly_collection,
                                group_loan_membership,
                                member,
                                self)
    
  end
  
  def create_contra_allowance_in_cycle_clearance_transaction_data
    AccountingService::UncollectibleDeclaration.cancel_in_cycle_clearance(self)
  end
  
  
  def self.create_object(params)
    new_object = self.new 
    
    new_object.group_loan_id                     = params[:group_loan_id]  
    new_object.group_loan_membership_id          = params[:group_loan_membership_id]  
    new_object.group_loan_weekly_collection_id   = params[:group_loan_weekly_collection_id]
    new_object.clearance_case = params[:clearance_case]
    # even if it is cleared in the cycle, or at the end of cycle, there still be allowance
    
    if new_object.save 
      new_object.update_amount 
    end
      
    
    return new_object
  end
  
  def update_object(params)
    if self.group_loan_weekly_collection.is_confirmed? or 
        self.group_loan_weekly_collection.is_collected? 
      self.errors.add(:generic_errors, "Pengumpulan mingguan terkumpul atau terkonfirmasi ")
      return self 
    end
     
     
    self.group_loan_id                     = params[:group_loan_id]
    self.group_loan_membership_id          = params[:group_loan_membership_id]  
    self.group_loan_weekly_collection_id   = params[:group_loan_weekly_collection_id]
    
    self.clearance_case = params[:clearance_case]
    
    if group_loan.first_uncollected_weekly_collection.id != self.group_loan_weekly_collection_id 
      
      msg = "Pengumpulan minggu #{group_loan_weekly_collection.week_number} tidak valid"
      self.errors.add(:group_loan_weekly_collection_id , msg  )
      return self 
    end
    
    
    self.update_amount if self.save  
  end
  
  def delete_object
    if self.is_collected?
      self.errors.add(:generic_errors, 'Sudah terkumpul. Tidak bisa di hapus')
      return self 
    end
    
    if self.group_loan_weekly_collection.is_confirmed? or 
        self.group_loan_weekly_collection.is_collected? 
      self.errors.add(:generic_errors, "Pengumpulan mingguan terkumpul atau terkonfirmasi ")
      return self 
    end
    
    self.destroy 
  end
  
  def collect( params ) 
    if self.clearance_case == UNCOLLECTIBLE_CLEARANCE_CASE[:end_of_cycle]
      msg =  "Penyelesaian tak tertagih dilakukan dengan cara pemotongan tabungan wajib"
      self.errors.add(:generic_errors, msg )
      return self 
    end
    
    if self.is_collected?
      self.errors.add(:generic_errors, "Sudah dikumpul")
      return self 
    end
    
    if params[:collected_at].nil? or not params[:collected_at].is_a?(DateTime)
      self.errors.add(:collected_at, "Harus ada tanggal pengumpulan")
      return self
    end
    
    if not self.group_loan_weekly_collection.is_confirmed? 
      self.errors.add(:generic_errors, "Weekly collection belum di konfirmasi")
      return self
    end
    
    self.is_collected = true 
    self.collected_at = params[:collected_at]
    self.save 
  end
  
  def clear(params)
    if not self.is_collected? 
      self.errors.add(:generic_errors, "Belum dikumpulkan oleh field officer")
      return self 
    end
    
    if not self.group_loan_weekly_collection.is_confirmed?
      self.errors.add(:generic_errors, "Belum konfirmasi pengumpulan mingguan")
      return self 
    end
    
    if self.is_cleared? 
      self.errors.add(:generic_errors, "Sudah di lunaskan")
      return self 
    end
    
    if params[:cleared_at].nil? or not params[:cleared_at].is_a?(DateTime)
      self.errors.add(:cleared_at, "Harus ada tanggal penutupan")
      return self 
    end
    
    self.is_cleared = true 
    self.cleared_at = params[:cleared_at]
  
    if self.save 
      # self.group_loan.update_bad_debt_allowance(  -1 * self.principal)
      # self.group_loan.update_potential_loss_interest_revenue( -1* self.group_loan_membership.group_loan_product.interest)
      
      # update the journal posting 
      
      # in cycle is by default. if it is not in-cycle, call the #clear_end_of_cycle method 
      if self.clearance_case == UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
        self.create_allowance_in_cycle_clearance_transaction_data
      end
    end
  end
  
  def uncollect
    if self.is_collected == false
      self.errors.add(:generic_errors, "Belum ada collection")
      return self 
    end
    
    
    self.is_collected = false 
    self.collected_at = nil
    self.save
  end
  
  def unclear
    if self.is_cleared == false
      self.errors.add(:generic_errors, "Belum ada clearance")
      return self 
    end
    
    self.is_cleared = false 
    self.cleared_at = nil
    
    
    if self.save
      # self.group_loan.update_bad_debt_allowance(   self.principal )
      # self.group_loan.update_potential_loss_interest_revenue( self.group_loan_membership.group_loan_product.interest)
      AccountingService::UncollectibleDeclaration.cancel_in_cycle_clearance(self)
    end
    
  end
  
  def clear_end_of_cycle
    self.is_cleared = true 
    self.cleared_at = self.group_loan.closed_at 
    if self.save
      # at the end of cycle -> must absorb all shite.
      # total amount to offset uang titipan and compulsory savings
      # their collateral: uang titipan and compulsory savings
      # burden: run_away_end_of_cycle_principal + total_amount weekly_collection for uncollectible_end_of_cycle_clearance
    else
      self.errors.messages.each {|x| puts "error message in uncollectible clearance: #{x}"}
    end
  end
  
end
