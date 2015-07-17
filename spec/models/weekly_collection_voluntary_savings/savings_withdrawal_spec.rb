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
    @member = @target_glm.member 
    @savings_amount = BigDecimal("50000")

    @se = SavingsEntry.create_object( 

        :savings_source_id      => nil  ,
        :savings_source_type    => nil ,
        :amount                 => @savings_amount,
        :savings_status         => SAVINGS_STATUS[:savings_account],
        :direction              => FUND_TRANSFER_DIRECTION[:incoming],
        :financial_product_id   => nil ,
        :financial_product_type => nil,
        :member_id              => @member.id 

        )

    @se.confirm(:confirmed_at => DateTime.now )
    @member.reload
  end

  it "should increase members total savings account" do
    @member.total_savings_account.should == @savings_amount
  end

  context "create weekly collection, voluntary savings withdrawal" do
    before(:each) do


      @amount = BigDecimal("15000")
      @glwc_vse=  GroupLoanWeeklyCollectionVoluntarySavingsEntry.create_object(
          :amount                            =>  @amount, 
          :group_loan_membership_id          => @target_glm.id , 
          :group_loan_weekly_collection_id   => @first_glwc.id ,
          :direction => FUND_TRANSFER_DIRECTION[:outgoing]
        )

      @first_glwc.collect(:collected_at => DateTime.now )
      @first_glwc.confirm(:confirmed_at => DateTime.now)
      @member.reload
    end

    it "should reduce the member's savings amount" do
      @member.total_savings_account.should == @savings_amount - @amount
    end

    it "should not be allowed to unconfirm savings entry" do
      @se.reload
      @se.unconfirm
      @se.errors.size.should_not == 0 
    end
  end


end

