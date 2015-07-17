module AccountingService
  class GroupLoanClosingPortCompulsorySavingsDepositTransient
    def GroupLoanClosingPortCompulsorySavingsDepositTransient.port_deposit_and_compulsory_savings_to_transient_account(group_loan, 
                compulsory_savings_amount, deposit) 
      compulsory_savings_amount = BigDecimal(compulsory_savings_amount) .truncate( 2 )
      deposit = BigDecimal(deposit  ).truncate(2)
      
      message = "Port Compulsory Savings: Group #{group_loan.name}, #{group_loan.group_number}"

      ta = TransactionData.create_object({
        :transaction_datetime => group_loan.closed_at,
        :description =>  message,
        :transaction_source_id => group_loan.id , 
        :transaction_source_type => group_loan.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:port_compulsory_savings_and_premature_clearance_deposit],
        :is_contra_transaction => false 
      }, true )
      
       



      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pending_group_loan_member_cash_return_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => compulsory_savings_amount  + deposit,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:uang_titipan_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => deposit,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:compulsory_savings_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => compulsory_savings_amount,
        :description => message
      )

      ta.confirm
      
    
    end
     
    
    

  end
end
