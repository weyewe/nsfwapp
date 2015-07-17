=begin
  UncollectiblePayment: can be paid in 2 mode: 
    1. in_cycle  : member passes $$ in the weekly collection
    2. end_of_cycle: will be deducted from the group's compulsory savings
    
    Mechanism for in_cycle payment:
    1. Field Officer collects from member => mark as collected.. produce receipt. 
    2. Field officer passes $$ to the cashier. Cashier  clears the uncollectible .
      
    For corner cases, always check:
    1. weekly_collection.amount_receivable 
    2. amount_receivable for the future weekly_collection
    3. compulsory_savings_returned post group_loan.close 
=end

 

require 'spec_helper'

describe GroupLoanWeeklyUncollectible do
  
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

    @group_loan = GroupLoan.create_object({
      :name                             => "Group Loan 1" ,
      :number_of_meetings => 3 
    })
    
    # create GLM
    Member.all.each do |member|
      glp_index = rand(0..1)
      selected_glp = @glp_array[glp_index]

      GroupLoanMembership.create_object({
        :group_loan_id => @group_loan.id,
        :member_id => member.id ,
        :group_loan_product_id => selected_glp.id
      })
    end
    
    @started_at = DateTime.new(2013,10,5,0,0,0)
    @disbursed_at = DateTime.new(2013,10,10,0,0,0)
    
    # start group loan 
    @group_loan.start(:started_at => @started_at)
    @group_loan.reload

    # disburse loan 
    @group_loan.disburse_loan(:disbursed_at => @disbursed_at)
    @group_loan.reload
    
    @first_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC").first
    @second_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[1]
    @third_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[2]
    @first_group_loan_weekly_collection.should be_valid 
    @first_group_loan_weekly_collection.collect(
      {
        :collected_at => DateTime.now 
      }
    )

    @first_group_loan_weekly_collection.is_collected.should be_truthy
    @first_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now)
    @first_group_loan_weekly_collection.reload
    @second_group_loan_weekly_collection.reload 
    @uncollectible_glm = @group_loan.active_group_loan_memberships[0] 
    @second_uncollectible_glm = @group_loan.active_group_loan_memberships[1] 
    @third_uncollectible_glm = @group_loan.active_group_loan_memberships[2] 
    
    @collected_at = DateTime.new(2013,11,4 , 0 ,0 ,0)
    @uncollectible_collected_at =  DateTime.new(2013,12,1 , 0 ,0 ,0)
    @closed_at = DateTime.new(2013,12,5,0,0,0)
    @withdrawn_at = DateTime.new(2013,12,6,0,0,0)
    @cleared_at=   DateTime.new(2013,11,5,0,0,0)
  end
  
  
  it 'should confirm the first group_loan_weekly_collection' do
    @first_group_loan_weekly_collection.is_collected.should be_truthy 
    @first_group_loan_weekly_collection.is_confirmed.should be_truthy 
  end
  
  it 'should create uncollectible_weekly_payment for first due weekly_collection' do
    @gl_wu =GroupLoanWeeklyUncollectible.create_object({
      :group_loan_id => @group_loan.id,
      :group_loan_membership_id => @uncollectible_glm.id ,
      :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id ,
      :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
    })
    
    @gl_wu.errors.messages.each {|x| puts "err_msg :#{x}"}
    @gl_wu.should be_valid 
  end
   
   
  
  context "create one uncollectible: impact on the weekly_collection.amount_receivable" do
    before(:each) do
      @initial_amount_receivable = @second_group_loan_weekly_collection.amount_receivable
      
      @initial_extract_uncollectible_weekly_payment_amount = @second_group_loan_weekly_collection.extract_uncollectible_weekly_payment_amount
      @initial_bad_debt_allowance = @group_loan.bad_debt_allowance
      @first_gl_wu = GroupLoanWeeklyUncollectible.create_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @uncollectible_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id  ,
        :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle] 
      })
      @group_loan.reload 
      
      @second_group_loan_weekly_collection.collect({
        :collected_at => DateTime.now 
      })
      
      @second_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now) 
      @group_loan.reload 
      @first_gl_wu.reload 
      @second_group_loan_weekly_collection.reload 
      
      @group_loan.reload
      
    end
    
    it "should have the uncollectible" do
      @first_gl_wu.should be_valid 
    end
    
    it "should confirm grouploan_weekly_collection" do
      @second_group_loan_weekly_collection.is_confirmed.should be_truthy
    end
    
    it "should create accounting posting for the uncollectible" do
      TransactionData.where(:transaction_source_id => @first_gl_wu.id, 
        :transaction_source_type => @first_gl_wu.class.to_s,
        :code => TRANSACTION_DATA_CODE[:group_loan_uncollectible_declaration]
      ).count.should == 1 

      a = TransactionData.where(:transaction_source_id => @first_gl_wu.id, 
        :transaction_source_type => @first_gl_wu.class.to_s,
        :code => TRANSACTION_DATA_CODE[:group_loan_uncollectible_declaration]
      ).first

      a.total_debit.should == a.total_credit
      a.is_confirmed.should be_truthy 
    end
    
    context "unconfirm the weekly collection" do
      before(:each) do
        @second_group_loan_weekly_collection.unconfirm 
      end
      
      it "should unconfirm weekly collection" do
        @second_group_loan_weekly_collection.reload
        @second_group_loan_weekly_collection.is_confirmed.should be_falsy
      end
      
      it "should create contra transaction" do
        contra = TransactionData.where(:transaction_source_id => @first_gl_wu.id, 
          :transaction_source_type => @first_gl_wu.class.to_s,
          :code => TRANSACTION_DATA_CODE[:group_loan_uncollectible_declaration],
          :is_contra_transaction => true 
        ).order("id DESC").first
        
        contra.is_confirmed.should be_truthy
      end
      
      
    end
    
    
  
  end
end


