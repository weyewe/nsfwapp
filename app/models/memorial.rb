class Memorial < ActiveRecord::Base
  has_many :memorial_details 
  
  
  validates_presence_of :description
  
  def self.active_objects
    self.where(:is_deleted => false ) 
  end
  
  def  active_memorial_details
    self.memorial_details
  end
  
  def self.create_object(params)
    new_object           = self.new
    
    new_object.transaction_datetime = params[:transaction_datetime]
    new_object.description      = params[:description] 
    
    if params[:transaction_datetime].nil? or not params[:transaction_datetime].is_a?(DateTime)
      new_object.errors.add(:transaction_datetime, "Harus ada tanggal Transaksi")
      return new_object 
    end

    if new_object.save
      new_object.code = Memorial.count.to_s
      new_object.is_deleted = false 
      new_object.save 
    end
    
    return new_object 
  end
  
  def update_object( params ) 
    if self.is_confirmed? 
      self.errors.add(:generic_errors, "Sudah di konfirmasi")
      return self 
    end
    
    if self.is_deleted?
      self.errors.add(:generic_errors, "Sudah dihapus")
      return self 
    end
    
    if params[:transaction_datetime].nil? or not params[:transaction_datetime].is_a?(DateTime)
      self.errors.add(:transaction_datetime, "Harus ada tanggal Transaksi")
      return self 
    end
    
    
    self.transaction_datetime = params[:transaction_datetime]
    self.description      = params[:description]
    self.save
    
    return self 
  end
  
  def total_debit
    self.memorial_details.where(:entry_case => NORMAL_BALANCE[:debit]).sum("amount ")
  end
  
  def total_credit
    self.memorial_details.where(:entry_case => NORMAL_BALANCE[:credit]).sum("amount")
  end
  
  def confirm( params )
    
    puts "gonna enter confirm"
    if params[:confirmed_at].nil? or not params[:confirmed_at].is_a?(DateTime)
      puts "44311.. this is confirm fail"
      self.errors.add(:confirmed_at, "Harus ada tanggal konfirmasi")
      return self 
    end
    
    
    if self.is_deleted
      self.errors.add(:generic_errors, "Sudah dihapus")
      return self 
    end
    
    if self.is_confirmed
      self.errors.add(:generic_errors, "sudah di konfirmasi")
      return self 
    end
    
    if self.total_debit != self.total_credit
      self.errors.add(:generic_errors, "Tidak balance. Debit: #{self.total_debit}, Credit: #{self.total_credit}")
      return self 
    end
    
    if self.memorial_details.count == 0 
      self.errors.add(:generic_errors, "Harus ada detail")
      return self
    end
    
    self.is_confirmed = true 
    self.confirmed_at = params[:confirmed_at]
    if self.save
    end
    AccountingService::MemorialTransaction.create_posting( self)
    return self 
  end
  
  def unconfirm 
    if self.is_deleted?
      self.errors.add(:generic_errors, "Sudah dihapus")
      return self 
    end
    
    if not self.is_confirmed
      self.errors.add(:generic_errors, "belum di konfirmasi")
      return self 
    end
    
    self.is_confirmed=  false 
    self.confirmed_at = nil 
    if self.save 
      AccountingService::MemorialTransaction.cancel_posting( self)
    end
    
    return self 
  end
  
  def delete_object
    if self.is_confirmed == true 
      self.errors.add(:generic_errors, "Sudah di konfirmasi")
      return self 
    end
    
    if self.memorial_details.count != 0 
      self.errors.add(:generic_errors, "Ada memorial detail")
      return self 
    end
    
    self.is_deleted = true 
    self.deleted_at = DateTime.now 
    self.save 
    
    return self 
  end
  
end
