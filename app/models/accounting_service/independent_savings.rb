module AccountingService
  class IndependentSavings
    def IndependentSavings.post_savings_account( savings_entry , multiplier  ) 
        member = savings_entry.member
        member_name = ""
        absolut_amount = savings_entry.amount 
        return if member.nil? 
        
        # message = "" 
        msg = ""
        main_cash_entry_case = 0 
        savings_account_entry_case = 0 
        
        if multiplier == -1 
          # message = "Voluntary Savings Withdrawal: Member #{member.name}, #{member.id_number}"
          msg = "#{member.name} (#{member.id_number})  Ambil Tab. Pribadi"
          main_cash_entry_case  = NORMAL_BALANCE[:credit]
          savings_account_entry_case = NORMAL_BALANCE[:debit]
        else
          # message = "Voluntary Savings Addition: Member #{member.name}, #{member.id_number}"
          msg = "#{member.name} (#{member.id_number})  Tambah Tab. Pribadi"
          main_cash_entry_case  = NORMAL_BALANCE[:debit]
          savings_account_entry_case = NORMAL_BALANCE[:credit]
        end
        
      
        
        
        ta = TransactionData.create_object({
          :transaction_datetime => savings_entry.confirmed_at,
          :description =>  msg,
          :transaction_source_id => savings_entry.id , 
          :transaction_source_type => savings_entry.class.to_s ,
          :code => TRANSACTION_DATA_CODE[:savings_account],
          :is_contra_transaction => false 
        }, true )



        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
          :entry_case          => main_cash_entry_case    ,
          :amount              => absolut_amount,
          :description => msg
        )

        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:voluntary_savings_leaf][:code]).id        ,
          :entry_case          => savings_account_entry_case  ,
          :amount              => absolut_amount,
          :description => msg
        )
  

        ta.confirm
    end
    
    def IndependentSavings.post_locked_savings_account( savings_entry , multiplier) 
        absolut_amount = savings_entry.amount 
        member = savings_entry.member
        # message = "" 
        msg = ""
        main_cash_entry_case = 0 
        savings_account_entry_case = 0 
        
        if multiplier == -1 
          # message = "Voluntary Savings Withdrawal: Member #{member.name}, #{member.id_number}"
          
          msg = "#{member.name} (#{member.id_number})  Ambil TMD"
          main_cash_entry_case  = NORMAL_BALANCE[:credit]
          savings_account_entry_case = NORMAL_BALANCE[:debit]
        else
          # message = "Voluntary Savings Addition: Member #{member.name}, #{member.id_number}"
          msg = "#{member.name} (#{member.id_number})  Tambah TMD"
          main_cash_entry_case  = NORMAL_BALANCE[:debit]
          savings_account_entry_case = NORMAL_BALANCE[:credit]
        end
        
         
        
        
        
        ta = TransactionData.create_object({
          :transaction_datetime => savings_entry.confirmed_at,
          :description =>  msg,
          :transaction_source_id => savings_entry.id , 
          :transaction_source_type => savings_entry.class.to_s ,
          :code => TRANSACTION_DATA_CODE[:locked_savings_account],
          :is_contra_transaction => false 
        }, true )



        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
          :entry_case          => main_cash_entry_case    ,
          :amount              => absolut_amount,
          :description => msg
        )

        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:locked_savings_leaf][:code]).id        ,
          :entry_case          => savings_account_entry_case  ,
          :amount              => absolut_amount,
          :description => msg
        )
  

        ta.confirm
    end
    
    def IndependentSavings.post_membership_savings_account( savings_entry , multiplier ) 
        absolut_amount = savings_entry.amount 
        member = savings_entry.member
        message = "" 
        main_cash_entry_case = 0 
        savings_account_entry_case = 0 
         
        if multiplier == -1 
          message = "Voluntary Savings Withdrawal: Member #{member.name}, #{member.id_number}"
          main_cash_entry_case  = NORMAL_BALANCE[:credit]
          savings_account_entry_case = NORMAL_BALANCE[:debit]
        else
          message = "Voluntary Savings Addition: Member #{member.name}, #{member.id_number}"
          main_cash_entry_case  = NORMAL_BALANCE[:debit]
          savings_account_entry_case = NORMAL_BALANCE[:credit]
        end
        
         
        
        
        
        ta = TransactionData.create_object({
          :transaction_datetime => savings_entry.confirmed_at,
          :description =>  message,
          :transaction_source_id => savings_entry.id , 
          :transaction_source_type => savings_entry.class.to_s ,
          :code => TRANSACTION_DATA_CODE[:membership_savings_account],
          :is_contra_transaction => false 
        }, true )



        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
          :entry_case          => main_cash_entry_case    ,
          :amount              => absolut_amount,
          :description => message
        )

        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:membership_savings_leaf][:code]).id        ,
          :entry_case          => savings_account_entry_case  ,
          :amount              => absolut_amount,
          :description => message
        )
  

        ta.confirm
    end
    
    def IndependentSavings.cancel_journal_posting(savings_entry )
      transaction_data_code = 0 
      if savings_entry.savings_status == SAVINGS_STATUS[:locked]
        transaction_data_code =  TRANSACTION_DATA_CODE[:locked_savings_account]
      elsif savings_entry.savings_status == SAVINGS_STATUS[:membership]
        transaction_data_code =  TRANSACTION_DATA_CODE[:membership_savings_account]
      elsif savings_entry.savings_status == SAVINGS_STATUS[:savings_account]
        transaction_data_code =  TRANSACTION_DATA_CODE[:savings_account]
      end
      
      
      last_transaction_data = TransactionData.where(
        :transaction_source_id => savings_entry.id , 
        :transaction_source_type => savings_entry.class.to_s ,
        :code => transaction_data_code ,
        :is_contra_transaction => false
      ).order("id DESC").first 

      last_transaction_data.create_contra_and_confirm if not last_transaction_data.nil?
    end
    

  end
end
