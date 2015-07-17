module AccountingService
  class UncollectibleDeclaration
    def UncollectibleDeclaration.create_uncollectible_declaration(group_loan,
                                group_loan_weekly_collection,
                                member,
                                uncollectible) 
      
      message = "Uncollectible Payment. GroupLoan: #{group_loan.name}, #{group_loan.group_number} " + 
                "Member: #{member.name}, #{member.id_number} " + 
                "Week: #{group_loan_weekly_collection.week_number}"

      ta = TransactionData.create_object({
        :transaction_datetime => group_loan_weekly_collection.collected_at,
        :description =>  message,
        :transaction_source_id => uncollectible.id , 
        :transaction_source_type => uncollectible.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_uncollectible_declaration],
        :is_contra_transaction => false 
      }, true )



      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_bda_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => uncollectible.principal,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => uncollectible.principal,
        :description => message
      )

      ta.confirm
    end
    
    def UncollectibleDeclaration.cancel_uncollectible_declaration(object)
      last_transaction_data = TransactionData.where(
        :transaction_source_id => object.id , 
        :transaction_source_type => object.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_uncollectible_declaration],
        :is_contra_transaction => false
      ).order("id DESC").first 

      last_transaction_data.create_contra_and_confirm if not last_transaction_data.nil?
    end
    
    def UncollectibleDeclaration.create_in_cycle_clearance(group_loan,
                                group_loan_weekly_collection,
                                group_loan_membership,
                                member,
                                uncollectible) 
    
      message = "Uncollectible Payment In-Cycle Clearance. GroupLoan: #{group_loan.name}, #{group_loan.group_number} " + 
                "Member: #{member.name}, #{member.id_number} " + 
                "Week: #{group_loan_weekly_collection.week_number}"

      glp = group_loan_membership.group_loan_product   

      ta = TransactionData.create_object({
        :transaction_datetime => uncollectible.collected_at,
        :description =>  message,
        :transaction_source_id => uncollectible.id , 
        :transaction_source_type => uncollectible.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_uncollectible_in_cycle_clearance],
        :is_contra_transaction => false 
      }, true )
      
    

 
      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => glp.weekly_payment_amount,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_interest_revenue_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => glp.interest,
        :description => message
      )
      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_bda_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => glp.principal,
        :description => message
      )
      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:compulsory_savings_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => glp.compulsory_savings,
        :description => message
      )

      ta.confirm
    end
    
    def UncollectibleDeclaration.cancel_in_cycle_clearance(object)
      last_transaction_data = TransactionData.where(
        :transaction_source_id => object.id , 
        :transaction_source_type => object.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_uncollectible_in_cycle_clearance],
        :is_contra_transaction => false
      ).order("id DESC").first 

      last_transaction_data.create_contra_and_confirm if not last_transaction_data.nil?
    end
    

  end
end
