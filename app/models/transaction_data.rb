class TransactionData < ActiveRecord::Base
  has_many :transaction_data_details 
  validates_presence_of :transaction_datetime 
  
  
  def self.active_objects
    self
  end
  
  def self.create_object( params, is_automated_transaction ) 
    new_object = self.new 
    new_object.transaction_datetime = params[:transaction_datetime]
    new_object.description = params[:description]
    new_object.code = params[:code]
    if is_automated_transaction
      new_object.transaction_source_id = params[:transaction_source_id]
      new_object.transaction_source_type = params[:transaction_source_type]
    end
    
    new_object.save 
    
    return new_object
  end
   
  def update_affected_accounts_due_to_confirmation
    # self.transaction_data_details.each do |ta_entry|
    #   account = ta_entry.account 
    #   account.update_amount_from_posting_confirm(ta_entry)
    # end
  end
  
  def update_affected_accounts_due_to_un_confirmation
    self.transaction_data_details.each do |ta_entry|
      account = ta_entry.account 
      account.update_amount_from_posting_unconfirm(ta_entry)
    end
  end
  
  def confirm
    if self.transaction_data_details.count == 0 
      self.errors.add(:generic_errors, "Tidak ada posting. Tidak bisa konfirmasi")
      return self
    end
    
    if self.total_debit != self.total_credit
      self.errors.add(:generic_errors, "Total debit (#{total_debit}) tidak sama dengan total credit (#{total_credit})")
      return self 
    end
    
    if self.total_debit == BigDecimal('0')  
      self.errors.add(:generic_errors, "Total jumlah transaksi tidak boleh 0")
      return self 
    end
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah dikonfirmasi")
      return self 
    end
    
    self.is_confirmed = true
    self.amount = self.total_credit 
    if self.save 
      self.update_affected_accounts_due_to_confirmation
    end
  end
  
  
  # to be called in the controller 
  def external_unconfirm
    if not self.transaction_source_id.nil? 
      self.errors.add(:generic_errors, "Can't modify the automated generated transaction")
      return self 
    end
    
    self.is_confirmed = false 
    if self.save
      self.update_affected_accounts_due_to_un_confirmation
    end
  end
  
  def unconfirm
    self.is_confirmed = false 
    if self.save
      self.update_affected_accounts_due_to_un_confirmation
    end
  end
  
  def total_debit
    self.transaction_data_details.where(:entry_case => NORMAL_BALANCE[:debit]).sum("amount")
  end
  
  
  
  def total_credit
    self.transaction_data_details.where(:entry_case => NORMAL_BALANCE[:credit]).sum("amount")
  end 
  
  # can only be called from the business rule 
  
  def internal_object_update(params)
  end
  
  def internal_object_destroy
  end
  
   
   
  def create_contra_and_confirm
    new_object = self.class.new 
    
    new_object.transaction_datetime = self.transaction_datetime
    new_object.description =  "[contra posting at #{DateTime.now}]" + self.description
    new_object.code = self.code 
    
    new_object.transaction_source_id = self.transaction_source_id
    new_object.transaction_source_type = self.transaction_source_type
    new_object.is_contra_transaction = true 
    new_object.save 
    
    self.transaction_data_details.each do |tdd|
      tdd.create_contra(new_object)
    end
    new_object.confirm 
  end
  
end
