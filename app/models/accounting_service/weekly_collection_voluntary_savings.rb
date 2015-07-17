module AccountingService
  class WeeklyCollectionVoluntarySavings
    def WeeklyCollectionVoluntarySavings.create_journal_posting(
          group_loan,
          group_loan_weekly_collection,
          savings_source) 
      
          message = "Weekly Collection Voluntary Savings: Group #{group_loan.name}, " + 
                  " #{group_loan.group_number}, week  #{group_loan_weekly_collection.week_number}"

          message = "[Penarikan] " if savings_source.direction == FUND_TRANSFER_DIRECTION[:outgoing]        
          ta = TransactionData.create_object({
            :transaction_datetime => group_loan_weekly_collection.collected_at,
            :description =>  message,
            :transaction_source_id => savings_source.id , 
            :transaction_source_type => savings_source.class.to_s ,
            :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection_voluntary_savings],
            :is_contra_transaction => false 
          }, true )

          if savings_source.direction == FUND_TRANSFER_DIRECTION[:incoming]
            TransactionDataDetail.create_object(
              :transaction_data_id => ta.id,        
              :account_id          => Account.find_by_code(ACCOUNT_CODE[:voluntary_savings_leaf][:code]).id      ,
              :entry_case          => NORMAL_BALANCE[:credit]     ,
              :amount              => savings_source.amount,
              :description => message
            )

            TransactionDataDetail.create_object(
              :transaction_data_id => ta.id,        
              :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id        ,
              :entry_case          => NORMAL_BALANCE[:debit]     ,
              :amount              => savings_source.amount,
              :description => message
            ) 
          else
            TransactionDataDetail.create_object(
              :transaction_data_id => ta.id,        
              :account_id          => Account.find_by_code(ACCOUNT_CODE[:voluntary_savings_leaf][:code]).id      ,
              :entry_case          => NORMAL_BALANCE[:debit]     ,
              :amount              => savings_source.amount,
              :description => message
            )

            TransactionDataDetail.create_object(
              :transaction_data_id => ta.id,        
              :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id        ,
              :entry_case          => NORMAL_BALANCE[:credit]     ,
              :amount              => savings_source.amount,
              :description => message
            ) 
          end
          


          ta.confirm


    end
    
    
  end
end
