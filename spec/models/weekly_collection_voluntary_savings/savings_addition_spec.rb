require 'spec_helper'

describe GroupLoanWeeklyCollection do
  
  before(:each) do
    # Account.create_base_objects
    (1..8).each do |number|
      Member.create_object({
        :name =>  "Member #{number}",
        :address => "Address alamat #{number}" ,
        :id_number => "342432#{number}"
      })
    end
    
    @total_weeks_1        = 8 
    @principal_1          = BigDecimal('20000')
    @interest_1           = BigDecimal("4000")
    @compulsory_savings_1 = BigDecimal("6000")
    @admin_fee_1          = BigDecimal('10000')
    @initial_savings_1          = BigDecimal('0')
    
    @group_loan_product_1 = GroupLoanProduct.create_object({
      :name => "Produk 1, 500 Ribu",
      :total_weeks        =>  @total_weeks_1              ,
      :principal          =>  @principal_1                ,
      :interest           =>  @interest_1                 , 
      :compulsory_savings        =>  @compulsory_savings_1       , 
      :admin_fee          =>  @admin_fee_1,
      :initial_savings          => @initial_savings_1
    }) 
    
    @total_weeks_2        = 8 
    @principal_2          = BigDecimal('15000')
    @interest_2           = BigDecimal("5000")
    @compulsory_savings_2 = BigDecimal("4000")
    @admin_fee_2          = BigDecimal('10000')
    @initial_savings_2          = BigDecimal('0')

    @group_loan_product_2 = GroupLoanProduct.create_object({
      :name => "Product 2, 800ribu",
      :total_weeks        =>  @total_weeks_2              ,
      :principal          =>  @principal_2                ,
      :interest           =>  @interest_2                 , 
      :compulsory_savings        =>  @compulsory_savings_2       , 
      :admin_fee          =>  @admin_fee_2     ,
      :initial_savings          => @initial_savings_2           
    })
    
    @glp_array  = [@group_loan_product_1, @group_loan_product_2]
    
    
    @started_at = DateTime.new(2013,9,5,0,0,0)
    @closed_at = DateTime.new(2013,12,5,0,0,0)
    @disbursed_at = DateTime.new(2013,10,10,0,0,0)
    @withdrawn_at = DateTime.new(2013,12,6,0,0,0)
    
    @collected_at = DateTime.new( 2013, 10,10, 0 , 0 , 0)
    @confirmed_at = DateTime.new( 2013, 10, 14, 0 , 0, 0)
    
    @group_loan = GroupLoan.create_object({
      :name                             => "Group Loan 1" ,
      :number_of_meetings => 3 
    })
    
    Member.all.each do |member|
      glp_index = rand(0..1)
      selected_glp = @glp_array[glp_index]

      GroupLoanMembership.create_object({
        :group_loan_id => @group_loan.id,
        :member_id => member.id ,
        :group_loan_product_id => selected_glp.id
      })
    end
    
    @group_loan.start(:started_at => @started_at )
    @group_loan.reload 
    
    @group_loan.disburse_loan(:disbursed_at => @disbursed_at )
    @group_loan.reload 
 

    @first_glwc = @group_loan.group_loan_weekly_collections.order("week_number ASC").first
    
    @target_glm = @group_loan.group_loan_memberships.first 

    @amount = BigDecimal("150000")
    @glwc_vse=  GroupLoanWeeklyCollectionVoluntarySavingsEntry.create_object(
        :amount                            =>  @amount, 
        :group_loan_membership_id          => @target_glm.id , 
        :group_loan_weekly_collection_id   => @first_glwc.id ,
        :direction => FUND_TRANSFER_DIRECTION[:incoming]
      )

    @first_glwc.collect(:collected_at => DateTime.now )
    @first_glwc.confirm(:confirmed_at => DateTime.now)
    @member = @target_glm.member
    @member.reload

  end

  it "should create the savings entry" do

    @glwc_vse.errors.size.should == 0 
    puts "total savings account: #{@member.total_savings_account.to_s}"

    @member.total_savings_account.should == @amount

  end

  it "should create one savings entry" do
    se = SavingsEntry.where(
                        :savings_source_id => @glwc_vse.id,
                        :savings_source_type => @glwc_vse.class.to_s
      ).first

    se.financial_product_id.should == @target_glm.group_loan_id 
    se.direction.should == FUND_TRANSFER_DIRECTION[:incoming]
    se.amount.should ==  @amount
  end

  it "should create one transaction data" do
    td = TransactionData.where(
        :transaction_source_id => @glwc_vse.id , 
            :transaction_source_type => @glwc_vse.class.to_s ,
      ).first 

    td.code.should  == TRANSACTION_DATA_CODE[:group_loan_weekly_collection_voluntary_savings]
  end
  

  context "unconfirm glwc and there is sufficient fund" do
    before(:each) do 
      @first_glwc.unconfirm
      @member.reload
    end

    it "should unconfirm glwc" do
      @first_glwc.is_confirmed.should be_falsy
    end

    it "should reduce the member's total savings amount" do 
      @member.total_savings_account.should == BigDecimal("0")
    end

    it "should destroy the savings entry" do
      SavingsEntry.where(
                        :savings_source_id => @glwc_vse.id,
                        :savings_source_type => @glwc_vse.class.to_s
      ).count ==0 
    end

    it "should create 2 transaction data: 1 contra and 1 non contra" do
      TransactionData.where(
        :transaction_source_id => @glwc_vse.id , 
            :transaction_source_type => @glwc_vse.class.to_s ,
      ).count == 2 

      TransactionData.where(
        :transaction_source_id => @glwc_vse.id , 
            :transaction_source_type => @glwc_vse.class.to_s ,
            :is_contra_transaction => true 
      ).count == 1

      TransactionData.where(
        :transaction_source_id => @glwc_vse.id , 
            :transaction_source_type => @glwc_vse.class.to_s ,
            :is_contra_transaction => false
      ).count == 1

    end
  end

  context "unconfirm glwc, but there is no sufficient fund" do
    before(:each) do
      @se = SavingsEntry.create_object( 

        :savings_source_id      => nil  ,
        :savings_source_type    => nil ,
        :amount                 => BigDecimal("50000"),
        :savings_status         => SAVINGS_STATUS[:savings_account],
        :direction              => FUND_TRANSFER_DIRECTION[:outgoing],
        :financial_product_id   => nil ,
        :financial_product_type => nil,
        :member_id              => @member.id 

        )

      @se.confirm(:confirmed_at => DateTime.now)

      @member.reload
    end

    it "should confirm savings entry" do
      @se.is_confirmed.should be_truthy
    end

    it "should deduct member's total savings account" do
      @member.total_savings_account.should == @amount - BigDecimal("50000")
    end

    context "unconfirm glwc" do
      before(:each) do
        @first_glwc.unconfirm
      end

      it "should produce errors" do
        @first_glwc.errors.size.should_not == 0 
        @first_glwc.reload
        @first_glwc.is_confirmed.should be_truthy
      end
    end
  end

end

