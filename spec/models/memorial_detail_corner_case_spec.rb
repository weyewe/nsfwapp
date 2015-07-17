require 'spec_helper'

describe MemorialDetail do
  
  before(:each) do
    @transaction_datetime = DateTime.now 
    @memorial = Memorial.create_object(
      :transaction_datetime => @transaction_datetime ,
      :description => "awesome description"
    )
    
    @leaf_account_debit = Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]) 
     
    @leaf_account_credit = Account.find_by_code(ACCOUNT_CODE[:voluntary_savings_leaf][:code])   
    
    @group_account_debit = Account.find_by_code(ACCOUNT_CODE[:cash_and_others][:code])  
    
    
    @amount = BigDecimal("150000")
    @memorial_detail_1 = MemorialDetail.create_object(
      :memorial_id => @memorial.id,
      :account_id  => @leaf_account_debit.id  ,
      :entry_case  => NORMAL_BALANCE[:debit] ,
      :amount      => @amount
    )
    
    @memorial_detail_2 = MemorialDetail.create_object(
      :memorial_id => @memorial.id,
      :account_id  => @leaf_account_credit.id  ,
      :entry_case  => NORMAL_BALANCE[:credit] ,
      :amount      => @amount  
    )
    
    @memorial.confirm(:confirmed_at => DateTime.now )
    
  end
   
  
  it "should not be allowed to create memorial detail from confirmed memorial" do
    @memorial_detail = MemorialDetail.create_object(
      :memorial_id => @memorial.id,
      :account_id  => @leaf_account_debit.id  ,
      :entry_case  => NORMAL_BALANCE[:debit] ,
      :amount      => @amount
    )
    
    @memorial_detail.errors.size.should_not == 0 
  end
  
  it "should create accounting posting" do
    last_transaction_data = TransactionData.where(
      :transaction_source_id => @memorial.id , 
      :transaction_source_type => @memorial.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:memorial_general],
      :is_contra_transaction => false
    ).order("id DESC").first
    
    last_transaction_data.should be_valid 
    
    last_transaction_data.transaction_data_details.where(
      :account_id => @memorial_detail_1.account_id,
      :entry_case => @memorial_detail_1.entry_case,
      :amount => @memorial_detail_1.amount 
    ).count.should ==  1 
    
    last_transaction_data.transaction_data_details.where(
      :account_id => @memorial_detail_2.account_id,
      :entry_case => @memorial_detail_2.entry_case,
      :amount => @memorial_detail_2.amount 
    ).count.should ==  1
  end
  
  it "should contra transaction on unconfirm" do
    @memorial.unconfirm
    
    TransactionData.where(
      :transaction_source_id => @memorial.id , 
      :transaction_source_type => @memorial.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:memorial_general],
      :is_contra_transaction => true
    ).order("id DESC").count.should == 1 
    
  
  end
  
  
  
  
end
