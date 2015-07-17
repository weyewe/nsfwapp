module AccountingService
  class WeeklyPayment
    def WeeklyPayment.create_journal_posting(group_loan,group_loan_weekly_collection, 
              total_compulsory_savings , total_principal,
              total_interest_revenue) 
      
        # message = "#{group_loan.name} #{TRANSACTION_DATA_CODE[:group_loan_weekly_collection][:text_message]} #{group_loan_weekly_collection.week_number}"
        # message = "Weekly Collection: Group #{group_loan.name}, #{group_loan.group_number}, week #{group_loan_weekly_collection.week_number}"
        

        glwc = group_loan_weekly_collection
        group_loan = glwc.group_loan
        collection_week_number = glwc.week_number

        group_name = group_loan.name 
        group_no = group_loan.group_number

        appendix = AccountingService::Utility.extract_appendix( group_loan )


        msg = "#{appendix}-#{group_no} #{group_name} Set.#{collection_week_number}"


        ta = TransactionData.create_object({
          :transaction_datetime => group_loan_weekly_collection.collected_at,
          :description =>  msg,
          :transaction_source_id => group_loan_weekly_collection.id , 
          :transaction_source_type => group_loan_weekly_collection.class.to_s ,
          :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection],
          :is_contra_transaction => false 
        }, true )



        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
          :entry_case          => NORMAL_BALANCE[:debit]     ,
          :amount              => total_compulsory_savings + total_principal +  total_interest_revenue,
          :description => msg
        )

        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_interest_revenue_leaf][:code]).id        ,
          :entry_case          => NORMAL_BALANCE[:credit]     ,
          :amount              => total_interest_revenue,
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
    
    def WeeklyPayment.cancel_journal_posting(group_loan_weekly_collection)
      last_transaction_data = TransactionData.where(
        :transaction_source_id => group_loan_weekly_collection.id , 
        :transaction_source_type => group_loan_weekly_collection.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection],
        :is_contra_transaction => false
      ).order("id DESC").first 

      last_transaction_data.create_contra_and_confirm if not last_transaction_data.nil?
    end
    

  end
end
