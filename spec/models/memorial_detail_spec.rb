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
    
    
  end
  
  it "should be allowed to create memorial detail" do
    @memorial_detail = MemorialDetail.create_object(
      :memorial_id => @memorial.id,
      :account_id  => @leaf_account_debit.id  ,
      :entry_case  => NORMAL_BALANCE[:debit] ,
      :amount      => BigDecimal("1000")
    )
    
    @memorial_detail.errors.messages.each do |x|
      puts "331 error message: #{x}"
    end
    @memorial_detail.errors.size.should == 0
    @memorial_detail.should be_valid
  end
  
  it "should not be allowed to create memorial detail if account == group account" do
    @memorial_detail = MemorialDetail.create_object(
      :memorial_id => @memorial.id,
      :account_id  => @group_account_debit.id  ,
      :entry_case  => NORMAL_BALANCE[:debit] ,
      :amount      => BigDecimal("1000")
    )
    
    @memorial_detail.errors.size.should_not == 0
    @memorial_detail.should_not be_valid
  end
  
  it "should not be allowed to create memorial detail if amount <= 0 " do
    @memorial_detail = MemorialDetail.create_object(
      :memorial_id => @memorial.id,
      :account_id  => @leaf_account_debit.id  ,
      :entry_case  => NORMAL_BALANCE[:debit] ,
      :amount      => BigDecimal("0")
    )
    @memorial_detail.should_not be_valid 
    
    @memorial_detail = MemorialDetail.create_object(
      :memorial_id => @memorial.id,
      :account_id  => @leaf_account_debit.id  ,
      :entry_case  => NORMAL_BALANCE[:debit] ,
      :amount      => BigDecimal("-100")
    )
    
    @memorial_detail.should_not be_valid 
  end

  
  context "create memorial set" do
    before(:each) do
      @amount = BigDecimal("150000")
      @memorial_detail = MemorialDetail.create_object(
        :memorial_id => @memorial.id,
        :account_id  => @leaf_account_debit.id  ,
        :entry_case  => NORMAL_BALANCE[:debit] ,
        :amount      => @amount
      )
    end
    
    it "should not allow confirm if debit != credit " do
      @memorial_detail_2 = MemorialDetail.create_object(
        :memorial_id => @memorial.id,
        :account_id  => @leaf_account_credit.id  ,
        :entry_case  => NORMAL_BALANCE[:credit] ,
        :amount      => @amount + BigDecimal("1000")
      )
      
      @memorial.reload
      @memorial.confirm(:confirmed_at => DateTime.now)
      @memorial.errors.size.should_not == 0 
    end
    
    it "should allow confirm if debit == credit " do
      @memorial_detail_2 = MemorialDetail.create_object(
        :memorial_id => @memorial.id,
        :account_id  => @leaf_account_credit.id  ,
        :entry_case  => NORMAL_BALANCE[:credit] ,
        :amount      => @amount  
      )
      
      @memorial.reload
      @memorial.confirm(:confirmed_at => DateTime.now)
      @memorial.errors.size.should == 0
      @memorial.is_confirmed.should be_truthy
    end
  end
  
  
  
  
end
