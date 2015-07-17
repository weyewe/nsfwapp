module AccountingService
  class GroupLoanClosingPersonalClearance
    def GroupLoanClosingPersonalClearance.bad_debt_allowance_compulsory_savings_deduction(group_loan, 
                glm, compulsory_savings_deduction_for_bad_debt) 
      message = "Member Bad Debt Allowance compulsory savings deduction: Group #{group_loan.name}, #{group_loan.group_number}" + 
                " member : #{glm.member.name}, #{glm.member.id_number}" 

      ta = TransactionData.create_object({
        :transaction_datetime => group_loan.closed_at,
        :description =>  message,
        :transaction_source_id => group_loan.id , 
        :transaction_source_type => group_loan.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_close_member_compulsory_savings_deduction_for_bad_debt_allowance],
        :is_contra_transaction => false 
      }, true )


 
      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_bda_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => compulsory_savings_deduction_for_bad_debt,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:compulsory_savings_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => compulsory_savings_deduction_for_bad_debt,
        :description => message
      )

      ta.confirm
    end
    
    def GroupLoanClosingPersonalClearance.interest_revenue_compulsory_savings_deduction(group_loan, 
                glm, compulsory_savings_deduction_for_interest_revenue) 
      message = "Member Interest Revenue compulsory savings deduction: Group #{group_loan.name}, #{group_loan.group_number}" + 
                " member : #{glm.member.name}, #{glm.member.id_number}" 

      ta = TransactionData.create_object({
        :transaction_datetime => group_loan.closed_at,
        :description =>  message,
        :transaction_source_id => group_loan.id , 
        :transaction_source_type => group_loan.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_close_member_compulsory_savings_deduction_for_bad_debt_allowance],
        :is_contra_transaction => false 
      }, true )


 
      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_interest_revenue_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => compulsory_savings_deduction_for_interest_revenue,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:compulsory_savings_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => compulsory_savings_deduction_for_interest_revenue,
        :description => message
      )

      ta.confirm
    end
    
    def GroupLoanClosingPersonalClearance.bad_debt_expense_clearance(group_loan, 
                glm, bad_debt_expense) 
      message = "Member Interest Revenue compulsory savings deduction: Group #{group_loan.name}, #{group_loan.group_number}" + 
                " member : #{glm.member.name}, #{glm.member.id_number}" 

      ta = TransactionData.create_object({
        :transaction_datetime => group_loan.closed_at,
        :description =>  message,
        :transaction_source_id => group_loan.id , 
        :transaction_source_type => group_loan.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_close_member_compulsory_savings_deduction_for_bad_debt_allowance],
        :is_contra_transaction => false 
      }, true )


 
      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_bda_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => bad_debt_expense,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        # account_receivable_allowance_expense 
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_arae_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => bad_debt_expense,
        :description => message
      )

      ta.confirm
    end
    
    
    
    

  end
end
