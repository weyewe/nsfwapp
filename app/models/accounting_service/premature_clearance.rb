module AccountingService
  class PrematureClearance
    def PrematureClearance.create_premature_clearance_posting(group_loan,
                                  member, 
                                  total_principal,
                                  total_interest, 
                                  total_compulsory_savings,
                                  premature_clearance) 
      
      # message = "PrematureClearance remaining weeks payment: Group #{group_loan.name}, #{group_loan.group_number}, Member: #{member.name}, #{member.id_number}"
      
      appendix = AccountingService::Utility.extract_appendix( group_loan )
      group_no = group_loan.group_number
      group_name = group_loan.name 
      
      msg = "#{member.name} (#{appendix}-#{group_no}) Pelunasan"

      ta = TransactionData.create_object({
        :transaction_datetime => premature_clearance.group_loan_weekly_collection.collected_at,
        :description =>  msg,
        :transaction_source_id => premature_clearance.id , 
        :transaction_source_type => premature_clearance.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_premature_clearance_remaining_weeks_payment],
        :is_contra_transaction => false 
      }, true )



      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => total_compulsory_savings + total_principal +  total_interest,
        :description => msg
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_interest_revenue_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => total_interest,
        :description => msg
      )
      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => total_principal,
        :description => msg
      )
      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:compulsory_savings_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => total_compulsory_savings,
        :description => msg
      )

      ta.confirm
    end
    
    def PrematureClearance.cancel_premature_clearance_posting(object)
      last_transaction_data = TransactionData.where(
        :transaction_source_id => object.id , 
        :transaction_source_type => object.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_premature_clearance_remaining_weeks_payment],
        :is_contra_transaction => false
      ).order("id DESC").first 

      last_transaction_data.create_contra_and_confirm if not last_transaction_data.nil?
    end
    
    
    
    def PrematureClearance.create_premature_clearance_deposit_posting(group_loan,
                                  member, 
                                  premature_clearance,
                                  premature_clearance_deposit_amount) 
  
      return if premature_clearance_deposit_amount == BigDecimal("0")
      message = "PrematureClearance uang titipan: Group #{group_loan.name}, #{group_loan.group_number}, Member: #{member.name}, #{member.id_number}"
      ta = TransactionData.create_object({
        :transaction_datetime => premature_clearance.group_loan_weekly_collection.collected_at,
        :description =>  message,
        :transaction_source_id => premature_clearance.id , 
        :transaction_source_type => premature_clearance.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_premature_clearance_deposit],
        :is_contra_transaction => false 
      }, true )



      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => premature_clearance_deposit_amount,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:uang_titipan_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => premature_clearance_deposit_amount,
        :description => message
      )


      ta.confirm

    end
    
    def PrematureClearance.cancel_premature_clearance_deposit_posting(object)
      last_transaction_data = TransactionData.where(
        :transaction_source_id => object.id , 
        :transaction_source_type => object.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_premature_clearance_deposit],
        :is_contra_transaction => false
      ).order("id DESC").first 

      last_transaction_data.create_contra_and_confirm if not last_transaction_data.nil?
    end
    
    def PrematureClearance.create_extra_revenue_from_rounding_up(group_loan, group_loan_weekly_collection, diff)
      return if diff == BigDecimal("0")
      message = "Pembulatan Nilai: Group #{group_loan.name}, #{group_loan.group_number}, week #{group_loan_weekly_collection.week_number}"
      ta = TransactionData.create_object({
        :transaction_datetime => self.collected_at,
        :description =>  message,
        :transaction_source_id => self.id , 
        :transaction_source_type => self.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection_round_up],
        :is_contra_transaction => false 
      }, true )



      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => diff,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:other_revenue_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => diff,
        :description => message
      )
      
      ta.confirm
    end

  end
end
