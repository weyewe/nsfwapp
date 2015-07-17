class TransactionDataDetail < ActiveRecord::Base
  belongs_to :account
  belongs_to :transaction_data
  
  validate :valid_account_id
  validate :valid_transaction_data_id 
  validate :valid_entry_case
  validate :valid_amount
  validate :transaction_data_must_not_be_confirmed 
  
  
  
  validates_presence_of :account_id, :entry_case, :amount, :transaction_data_id 
  
  def all_fields_present?
    account_id.present? and 
    entry_case.present? and 
    amount.present? and 
    transaction_data_id.present? 
  end
  
  def valid_account_id
    return if not self.all_fields_present? 
    
    begin
      account = Account.find account_id 
      if account.account_case != ACCOUNT_CASE[:ledger]
        self.errors.add(:account_id , "Harus berupa ledger account")
        return self 
      end
    rescue
      self.errors.add(:account_id, "Harus memilih account") 
      return self 
    end
    
  end
  
  def valid_transaction_data_id
    return if not self.all_fields_present? 
    
    begin
      TransactionData.find transaction_data_id 
    rescue
      self.errors.add(:transaction_data_id, "Harus memilih account") 
      return self 
    end
  end
  
  def valid_entry_case
    return if not self.all_fields_present? 
    if not [NORMAL_BALANCE[:debit],
      NORMAL_BALANCE[:credit]].include?(entry_case)
      self.errors.add(:entry_case, "Harus memilih tipe posting: debit atau credit")
      return self 
    end
  end
  
  def valid_amount
    return if not self.all_fields_present? 
    
    if self.amount <= BigDecimal("0")
      self.errors.add(:amount, "Harus positive")
      return self 
    end
  end
  
  def transaction_data_must_not_be_confirmed
    return if not self.all_fields_present?
    return if self.persisted? 
    
    
    
    # try to do TransactionData.find 0 << will raise exception 
    begin
      transaction_data = TransactionData.find transaction_data_id 
      if transaction_data.is_confirmed?
        self.errors.add(:generic_errors, "Transaction sudah di konfirmasi")
      end
    rescue 
      return
    end
    
  end
  
  def self.create_object( params) 
    
    new_object = self.new 
    new_object.transaction_data_id = params[:transaction_data_id]
    new_object.account_id = params[:account_id]
    new_object.entry_case = params[:entry_case]
    new_object.amount = BigDecimal(params[:amount] || '0')
    new_object.description = params[:description] 
    new_object.save 
    
    return new_object
  end
  
  def create_contra(new_transaction_data)
    
    new_object = self.class.new 
    new_object.transaction_data_id = new_transaction_data.id
    new_object.account_id = self.account_id
    if self.entry_case ==  NORMAL_BALANCE[:credit]  
      new_object.entry_case =  NORMAL_BALANCE[:debit]  
    else
      new_object.entry_case =  NORMAL_BALANCE[:credit]  
    end
    new_object.amount = self.amount
    new_object.description = "contra post #{DateTime.now} " + self.description
    new_object.save
    
    
  end
end
