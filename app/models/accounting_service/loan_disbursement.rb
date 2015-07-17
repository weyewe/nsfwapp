module AccountingService
  class LoanDisbursement


    def LoanDisbursement.create_loan_disbursement(object) 
      
      # msg = "Loan Disbursement #{object.name}, GroupNumber: #{object.group_number}"


      group_no = object.group_number
      group_name = object.name 
      appendix = AccountingService::Utility.extract_appendix( object) 
      msg = "Adm (#{appendix}-#{group_no}) #{group_name}"
      
      ta = TransactionData.create_object({
        :transaction_datetime => object.disbursed_at,
        :description => msg ,
        :transaction_source_id => object.id , 
        :transaction_source_type => object.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:loan_disbursement],
        :is_contra_transaction => false 
      }, true )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => object.start_fund,
        :description => "Piutang Pinjaman Sejahtera dari Group #{object.name}, #{object.group_number} "
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => object.admin_fee_revenue,
        :description => "Pendapatan admin fee dari Group #{object.name}, #{object.group_number} "
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => object.start_fund,
        :description => "Penggunaan cash untuk loan disbursement dari Group #{object.name}, #{object.group_number} "
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_administration_revenue_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => object.admin_fee_revenue,
        :description => "Pendapatan admin fee dari Group #{object.name}, #{object.group_number} "
      )

      ta.confirm
    end
    
    def LoanDisbursement.undo_loan_disbursement(object)
      last_transaction_data = TransactionData.where(
        :transaction_source_id => object.id , 
        :transaction_source_type => object.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:loan_disbursement],
        :is_contra_transaction => false
      ).order("id DESC").first 

      last_transaction_data.create_contra_and_confirm if not last_transaction_data.nil?
    end

  end
end
