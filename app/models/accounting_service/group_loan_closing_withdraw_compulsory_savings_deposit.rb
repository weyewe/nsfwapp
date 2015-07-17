module AccountingService
  class GroupLoanClosingWithdrawCompulsorySavingsDeposit
    def GroupLoanClosingWithdrawCompulsorySavingsDeposit.add_round_down_revenue(group_loan) 
      message = "Round down revenue: Group #{group_loan.name}, #{group_loan.group_number}." + 
                " Amount: #{group_loan.round_down_compulsory_savings_return_revenue}." 

      ta = TransactionData.create_object({
        :transaction_datetime => group_loan.closed_at,
        :description =>  message,
        :transaction_source_id => group_loan.id , 
        :transaction_source_type => group_loan.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_close_withdrawal_return_rounding_down_revenue],
        :is_contra_transaction => false 
      }, true )


 
      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:other_revenue_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => group_loan.round_down_compulsory_savings_return_revenue,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pending_group_loan_member_cash_return_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => group_loan.round_down_compulsory_savings_return_revenue,
        :description => message
      )

      ta.confirm
    end
    
    def GroupLoanClosingWithdrawCompulsorySavingsDeposit.compulsory_savings_and_deposit_return(group_loan, amount ) 
      amount = BigDecimal( amount ).truncate(2)
      # message = "Compulsory Savings + Deposit return: Group #{group_loan.name}, #{group_loan.group_number}." + 
      #           " Amount: #{amount}." 

      group_no = group_loan.group_number
      group_name = group_loan.name 

      appendix = AccountingService::Utility.extract_appendix( group_loan )

      msg = "Bagi tab.  (#{appendix}-#{group_no}) #{group_name}"

    
      ta = TransactionData.create_object({
        :transaction_datetime => group_loan.closed_at,
        :description =>  msg,
        :transaction_source_id => group_loan.id , 
        :transaction_source_type => group_loan.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_close_withdrawal_return],
        :is_contra_transaction => false 
      }, true )


 
      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => amount,
        :description => msg
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pending_group_loan_member_cash_return_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => amount,
        :description => msg
      )

      ta.confirm
    end
    
   
    
    
    

  end
end
