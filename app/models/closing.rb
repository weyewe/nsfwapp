class Closing < ActiveRecord::Base
  
  validates_presence_of :end_period
  
  validate :end_period_must_be_later_than_any_start_period
  has_many :valid_combs
  
  def end_period_must_be_later_than_any_start_period
    return if not end_period.present? 
    
    current_end_period = self.end_period 
    
    
    if self.persisted?
      current_closing_id = self.id 
      if Closing.where{
        ( id.not_eq current_closing_id ) & (
          ( start_period.gte  current_end_period ) | 
          ( end_period.gte current_end_period )
        )
        
      }.count != 0 
        self.errors.add(:end_period, "Sudah ada closing yang tanggal mulai lebih akhir daripada tanggal end_period anda")
        return self 
      end
      
    else
      if Closing.where{
        ( start_period.gte  current_end_period ) | 
        ( end_period.gte current_end_period )
      }.count != 0 
        self.errors.add(:end_period, "Sudah ada closing yang tanggal mulai lebih akhir daripada tanggal end_period anda")
        return self 
      end
    end
    
  end
  
  def self.create_object(params)
    
    new_object = self.new 
    
    
    if params[:end_period].nil? or not params[:end_period].is_a?(DateTime)
      new_object.errors.add(:end_period, "Harus ada tanggal Akhir closing")
      return new_object 
    end
    
    new_object.end_period = params[:end_period]
    new_object.description = params[:description]
    
    if new_object.save
      new_object.update_start_period
      
    end
    
    return new_object
  end
  
  def update_object( params ) 
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah di konfirmasi")
      return self 
    end
    
    if params[:end_period].nil? or not params[:end_period].is_a?(DateTime)
      self.errors.add(:end_period, "Harus ada tanggal Akhir closing")
      return self 
    end
    
    
    self.end_period = params[:end_period]
    self.description = params[:description]
    
    if self.save
      
      
    end
    
    return self 
  end
  
  def previous_closing 
    previous_closing = nil 
    current_end_period = self.end_period
    if self.persisted?
      current_id = self.id 
      previous_closing = Closing.where{
        (id.not_eq current_id) & (
          (end_period.lt current_end_period)
        )
        
      }.order("id DESC").first
    else
      previous_closing = Closing.where{
        (end_period.lt current_end_period)
      }.order("id DESC").first
    end
    
    return previous_closing 
  end
  
  def update_start_period
    current_id =  self.id 
    current_end_period = self.end_period 
    
    
    
    
    
    if previous_closing.nil?
      self.is_first_closing = true 
    else
      self.start_period = previous_closing.end_period
    end
    
    self.save 
  end
  
  
  def generate_valid_combs_for_non_children
    Account.roots.each do |x|
      
      next if x.children.count != 0 
      
      
      valid_comb = ValidComb.create_object(
        :account_id => x.id,
        :closing_id => self.id,
        :amount => BigDecimal("0"),
        :entry_case => x.normal_balance
      )
      
    end
    
    
  end
  
  
  
  def generate_valid_combs
    start_transaction = start_period
    end_transaction = end_period
    
    
    leaves_account = Account.all_ledger_accounts
    
    
    
    leaves_account_id_list = leaves_account.map{|x| x.id }
    
    leaves_account.each do |leaf_account|
      valid_comb_amount = BigDecimal("0")
      
      total_debit = BigDecimal("0")
      total_credit = BigDecimal("0")
      
      if not start_transaction.nil?
        total_debit = TransactionDataDetail.joins(:transaction_data).where{
          ( transaction_data.transaction_datetime.gte start_transaction) & 
          ( transaction_data.transaction_datetime.lt end_transaction) & 
          ( account_id.eq leaf_account.id ) & 
          ( entry_case.eq NORMAL_BALANCE[:debit])
        }.sum("amount")

        total_credit = TransactionDataDetail.joins(:transaction_data).where{
          ( transaction_data.transaction_datetime.gte start_transaction) & 
          ( transaction_data.transaction_datetime.lt end_transaction) & 
          ( account_id.eq leaf_account.id ) & 
          ( entry_case.eq NORMAL_BALANCE[:credit])
        }.sum("amount")
      else
        total_debit = TransactionDataDetail.joins(:transaction_data).where{
          ( transaction_data.transaction_datetime.lt end_transaction) & 
          ( account_id.eq leaf_account.id ) & 
          ( entry_case.eq NORMAL_BALANCE[:debit])
        }.sum("amount")

        total_credit = TransactionDataDetail.joins(:transaction_data).where{
          ( transaction_data.transaction_datetime.lt end_transaction) & 
          ( account_id.eq leaf_account.id ) & 
          ( entry_case.eq NORMAL_BALANCE[:credit])
        }.sum("amount")
      end
      
      
      if leaf_account.normal_balance == NORMAL_BALANCE[:debit]
        valid_comb_amount = total_debit - total_credit
      else
        valid_comb_amount = total_credit -  total_debit
      end
      
      
      final_valid_comb_amount = valid_comb_amount + ValidComb.previous_closing_valid_comb_amount( previous_closing, leaf_account )
      
      entry_case = leaf_account.normal_balance  
      
      if final_valid_comb_amount < BigDecimal("0")
        entry_case = NORMAL_BALANCE[:debit] if leaf_account.normal_balance == NORMAL_BALANCE[:credit] 
        entry_case = NORMAL_BALANCE[:credit] if leaf_account.normal_balance == NORMAL_BALANCE[:debit] 
      end
      
      
      puts " #{leaf_account.name} (#{leaf_account.code}) :: #{valid_comb_amount} "
      
      
      
      valid_comb = ValidComb.create_object(
        :account_id => leaf_account.id,
        :closing_id => self.id,
        :amount => final_valid_comb_amount.abs,
        :entry_case => entry_case
      )
      
      
      
    end
    
    
    
    parent_id_list = leaves_account.map{|x| x.parent_id }.uniq
    
    if parent_id_list.length != 0
      generate_parent_valid_combs(  parent_id_list ) 
    end
    
  end
  
  def print_balance_sheet
    self.valid_combs.joins(:account).order("accounts.code ASC").each do |valid_comb|
      puts "[#{valid_comb.account.code}] #{valid_comb.account.name} = #{valid_comb.amount}"
    end
  end
  
  def generate_parent_valid_combs( node_id_list )
    node_account_list = Account.where(:id => node_id_list)
    
    node_account_list.each do | node | 
      
      next if ValidComb.where(:closing_id => self.id, :account_id => node.id).count == 1 
        
      
      children = node.children
      
      total_debit = ValidComb.where(
        :closing_id => self.id,
        :account_id => node.children.map{|x| x.id},
        :entry_case => NORMAL_BALANCE[:debit]
      ).sum("amount")
      
      
      total_credit = ValidComb.where(
        :closing_id => self.id,
        :account_id => node.children.map{|x| x.id},
        :entry_case => NORMAL_BALANCE[:credit]
      ).sum("amount")
      
      valid_comb_amount= BigDecimal("0")
      
      if node.normal_balance == NORMAL_BALANCE[:debit]
        valid_comb_amount = total_debit - total_credit
      else
        valid_comb_amount = total_credit -  total_debit
      end
      
      
      final_valid_comb_amount = valid_comb_amount + ValidComb.previous_closing_valid_comb_amount( previous_closing, node )
      
      entry_case = node.normal_balance  
      
      if final_valid_comb_amount < BigDecimal("0")
        entry_case = NORMAL_BALANCE[:debit] if node.normal_balance == NORMAL_BALANCE[:credit] 
        entry_case = NORMAL_BALANCE[:credit] if node.normal_balance == NORMAL_BALANCE[:debit] 
      end
      
      
      valid_comb = ValidComb.create_object(
        :account_id => node.id,
        :closing_id => self.id,
        :amount => final_valid_comb_amount.abs,
        :entry_case => entry_case
      )
      
      
    end
    
    parent_id_list = node_account_list.map{|x| x.parent_id }.uniq
    
    if parent_id_list.length != 0
      generate_parent_valid_combs(  parent_id_list ) 
    end
  end
  
  
  def extract_closing_entries
    
    # get all expense account, find the balancer amount
    expense_account_list = Account.where(
      :code => [
        ACCOUNT_CODE[:coop_expense][:code],
        ACCOUNT_CODE[:other_expense][:code],
        ACCOUNT_CODE[:operating_expense][:code],
        ACCOUNT_CODE[:financial_expense][:code],
      ]
    ) 
    
    total_debit = ValidComb.where(
        :closing_id => self.id, 
        :account_id => expense_account_list.map{|x| x.id },
        :entry_case => NORMAL_BALANCE[:debit]
    ).sum("amount")
    
    total_credit = ValidComb.where(
        :closing_id => self.id, 
        :account_id => expense_account_list.map{|x| x.id },
        :entry_case => NORMAL_BALANCE[:credit]
    ).sum("amount")
    
    expense_closing_entries_amount = total_debit - total_credit 
    
    self.expense_adjustment_amount  = expense_closing_entries_amount.abs
    if expense_closing_entries_amount < BigDecimal("0")
      self.expense_adjustment_case = NORMAL_BALANCE[:debit]
    else
      self.expense_adjustment_case = NORMAL_BALANCE[:credit]
    end
       
    # get all revenue account, find the balancer amount 
    revenue_account_list = Account.where(
      :code => [
        ACCOUNT_CODE[:other_revenue][:code],
        ACCOUNT_CODE[:operating_revenue][:code] 
      ]
    )
    
    total_debit = ValidComb.where(
        :closing_id => self.id, 
        :account_id => revenue_account_list.map{|x| x.id },
        :entry_case => NORMAL_BALANCE[:debit]
    ).sum("amount")
    
    total_credit = ValidComb.where(
        :closing_id => self.id, 
        :account_id => revenue_account_list.map{|x| x.id },
        :entry_case => NORMAL_BALANCE[:credit]
    ).sum("amount")
    
    revenue_closing_entries_amount = total_credit - total_debit
    
    self.revenue_adjustment_amount  = revenue_closing_entries_amount.abs
    if revenue_closing_entries_amount < BigDecimal("0")
      self.revenue_adjustment_case = NORMAL_BALANCE[:credit]
    else
      self.revenue_adjustment_case = NORMAL_BALANCE[:debit]
    end
    
    net_earning_closing_entries = revenue_closing_entries_amount - expense_closing_entries_amount
    
    
    
    self.net_earnings_amount  = net_earning_closing_entries.abs
    if net_earning_closing_entries < BigDecimal("0")
      self.net_earnings_case = NORMAL_BALANCE[:debit]
    else
      self.net_earnings_case = NORMAL_BALANCE[:credit]
    end
    
    self.save 
  end
  
  
  def confirm( params  )
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah di konfirmasi")
      return self 
    end
    
    
    
    self.is_confirmed = true 
    self.confirmed_at = DateTime.now 
    
    if self.save 
      # self.generate_closing_entries # revenue = 0, expense = 0
      self.generate_valid_combs
      
      self.generate_valid_combs_for_non_children
      # self.extract_closing_entries
    end 
    
    
    return self 
    
    
  end
end
