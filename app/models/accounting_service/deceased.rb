module AccountingService
  class Deceased
    def Deceased.create_bad_debt_allocation(group_loan, member, group_loan_membership,group_loan_deceased_clearance) 
      
      remaining_principal = group_loan_deceased_clearance.principal_return



      message = "Deceased Bad Debt Allowance: Group #{group_loan.name}, #{group_loan.group_number}, member: #{member.name}"

      ta = TransactionData.create_object({
        :transaction_datetime => group_loan_deceased_clearance.member.deceased_at,
        :description =>  message,
        :transaction_source_id => group_loan_deceased_clearance.id , 
        :transaction_source_type => group_loan_deceased_clearance.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_deceased_declaration],
        :is_contra_transaction => false 
      }, true )



      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_bda_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => remaining_principal,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => remaining_principal,
        :description => message
      )
      ta.confirm
    end
    

    def Deceased.undo_deceased(object)
      last_transaction_data = TransactionData.where(
        :transaction_source_id => object.id , 
        :transaction_source_type => object.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_deceased_declaration],
        :is_contra_transaction => false
      ).order("id DESC").first 

      last_transaction_data.create_contra_and_confirm if not last_transaction_data.nil?
    end

    

  end
end
