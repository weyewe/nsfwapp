module AccountingService
  class MemorialTransaction
    def MemorialTransaction.create_posting(memorial) 
      ta = TransactionData.create_object({
        :transaction_datetime => memorial.transaction_datetime,
        :description => "Memorial Posting" ,
        :transaction_source_id => memorial.id , 
        :transaction_source_type => memorial.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:memorial_general],
        :is_contra_transaction => false 
      }, true )
      
      
      memorial.memorial_details.each do |md|
          
          TransactionDataDetail.create_object(
            :transaction_data_id => ta.id,        
            :account_id          => md.account_id       ,
            :entry_case          => md.entry_case ,
            :amount              => md.amount,
            :description => memorial.description 
          )
        
      end

      ta.confirm
    end
    
    def MemorialTransaction.cancel_posting(object)
      last_transaction_data = TransactionData.where(
        :transaction_source_id => object.id , 
        :transaction_source_type => object.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:memorial_general],
        :is_contra_transaction => false
      ).order("id DESC").first 

      last_transaction_data.create_contra_and_confirm if not last_transaction_data.nil?
    end

  end
end
