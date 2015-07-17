module AccountingService
  class GroupLoanClosing
    def GroupLoanClosing.clear_group_bad_debt(group_loan , capital_deduction_for_bad_debt_allowance,
              capital_deduction_for_interest_revenue, bad_debt_expense)
      
      return if capital_deduction_for_bad_debt_allowance == BigDecimal("0") &&
                  capital_deduction_for_interest_revenue == BigDecimal("0") && 
                  bad_debt_expense == BigDecimal("0")
                  
      message = "Group Loan Closing compulsory savings + deposit deduction: Group #{group_loan.name}, #{group_loan.group_number}"

      ta = TransactionData.create_object({
        :transaction_datetime => group_loan.closed_at,
        :description =>  message,
        :transaction_source_id => group_loan.id , 
        :transaction_source_type => group_loan.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_close_compulsory_savings_deposit_deduction_for_bad_debt_allowance],
        :is_contra_transaction => false 
      }, true )


      # posting to account for capital deduction, bad debt allowance
      if capital_deduction_for_bad_debt_allowance  + capital_deduction_for_interest_revenue != BigDecimal("0")
        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:pending_group_loan_member_cash_return_leaf][:code]).id      ,
          :entry_case          => NORMAL_BALANCE[:debit]     ,
          :amount              => capital_deduction_for_bad_debt_allowance  + capital_deduction_for_interest_revenue,
          :description => message
        )
      end
      
    # total_debit: capital_deduction_for_bad_debt_allowance + capital_deduction_for_interest_revenue + bad_debt_expense
    # total_credit: capital_deduction_for_interest_revenue + capital_deduction_for_bad_debt_allowance + bad_debt_expense
      
      
      if capital_deduction_for_interest_revenue != BigDecimal("0")
        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_interest_revenue_leaf][:code]).id        ,
          :entry_case          => NORMAL_BALANCE[:credit]     ,
          :amount              => capital_deduction_for_interest_revenue,
          :description => message
        )
      end
      
      
      
      
      if capital_deduction_for_bad_debt_allowance + bad_debt_expense != BigDecimal("0")
        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_bda_leaf][:code]).id        ,
          :entry_case          => NORMAL_BALANCE[:credit]     ,
          :amount              => capital_deduction_for_bad_debt_allowance + bad_debt_expense,
          :description => message
        )
      end
      
      
      
      
      
      if bad_debt_expense != BigDecimal("0")
        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        # account_receivable_allowance_expense 
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_arae_leaf][:code]).id        ,
          :entry_case          => NORMAL_BALANCE[:debit]     ,
          :amount              => bad_debt_expense,
          :description => message
        )
      end
      
      
      
      

      ta.confirm
      
      
    end
    

  end
end
