require 'spec_helper'

describe GroupLoan do
  
  before(:each) do
    # Account.create_base_objects
    # create users 
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
    
    @started_at = DateTime.new(2013,10,5,0,0,0)
    @disbursed_at = DateTime.new(2013,10,10,0,0,0)
    @closed_at = DateTime.new(2013,12,5,0,0,0)
    @withdrawn_at = DateTime.new(2013,12,6,0,0,0)
    
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
    
    @group_loan.start(:started_at => @started_at) 
    @group_loan.reload
    
    
    @group_loan.disburse_loan(:disbursed_at => @disbursed_at)
    
     
    count = 1
    @uncollectible_glm = @group_loan.group_loan_memberships.first 
    @group_loan.group_loan_weekly_collections.order("id ASC").each do |x|
      if count == 2 
        
        @first_gl_wu = GroupLoanWeeklyUncollectible.create_object({
          :group_loan_id => @group_loan.id,
          :group_loan_membership_id => @uncollectible_glm.id ,
          :group_loan_weekly_collection_id => x.id  ,
          :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:end_of_cycle] 
        })
      end
      
      x.collect(:collected_at => DateTime.now)
      x.confirm(:confirmed_at => DateTime.now)
      count +=1 
    end
    
    @group_loan.reload 
    
    @closed_at = DateTime.now + 2.days
    @group_loan.close(:closed_at => @closed_at) 
    @group_loan.errors.messages.each do |msg|
      puts "error message: #{msg}"
    end
  end
  
  it "should close the group loan" do
    @group_loan.is_closed.should be_truthy 
    @group_loan.errors.messages.each do |msg|
      puts "error message: #{msg}"
    end
    @group_loan.closed_at.should_not be_nil 
    
    @group_loan.errors.size.should == 0 
  end
  
  it "should create transaction data for porting compulsory savings to transient" do
    TransactionData.where(:transaction_source_id => @group_loan.id, 
      :transaction_source_type => @group_loan.class.to_s,
      :code => TRANSACTION_DATA_CODE[:port_compulsory_savings_and_premature_clearance_deposit]
    ).count.should == 1
    
    a = TransactionData.where(:transaction_source_id => @group_loan.id, 
      :transaction_source_type => @group_loan.class.to_s,
      :code => TRANSACTION_DATA_CODE[:port_compulsory_savings_and_premature_clearance_deposit]
    ).order("id DESC").first 
    
    a.is_confirmed.should be_truthy 
  end
  
  it "should empty out all member's compulsory savings" do
    @group_loan.group_loan_memberships.each do |glm|
      glm.total_compulsory_savings.should == BigDecimal("0")
    end
  end
  
  it "should deduct member's compulsory savings for interest and principal" do
    @uncollectible_glm.reload
    @uncollectible_glm.compulsory_savings_deduction_for_interest_revenue.should == @uncollectible_glm.group_loan_product.interest 
    @uncollectible_glm.compulsory_savings_deduction_for_bad_debt_allowance.should == @uncollectible_glm.group_loan_product.principal 
  end
  
   
  
  it "should recap all member's compulsory savings to the transient state" do
    expected_amount = BigDecimal("0")
    @group_loan.group_loan_memberships.each do |glm|
      glm.total_compulsory_savings.should == BigDecimal("0")
      expected_amount += glm.group_loan_product.compulsory_savings  * @group_loan.number_of_collections
    end
    
    puts "actual: #{@group_loan.total_compulsory_savings_pre_closure}"
    puts "expected: #{expected_amount}"
    puts "interest: #{@uncollectible_glm.group_loan_product.interest}"
    puts "principal: #{@uncollectible_glm.group_loan_product.principal}"
    @group_loan.total_compulsory_savings_pre_closure.should == ( expected_amount - 
            (@uncollectible_glm.group_loan_product.principal + 
            @uncollectible_glm.group_loan_product.interest +
            @uncollectible_glm.group_loan_product.compulsory_savings) ) 
  end
  
end
