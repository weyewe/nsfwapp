# Case 1: member pass away mid shite 

=begin
1. Handle the Premature Clearance case
    1. Member declares premature clearance on week n
    2. It will start to be active on week n + 1. Naturally, there can't be premature clearance 
      on the last week
      since there is no week n+1
    3.
=end

require 'spec_helper'

describe GroupLoan do
  
  before(:each) do
    
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
    @closed_at = DateTime.new(2013,12,5,0,0,0)
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
    # puts "FROM THE SPEC: Gonna confirm first weekly_collection"
    @first_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now )
    @first_group_loan_weekly_collection.reload
    @second_group_loan_weekly_collection.reload 
    @premature_clearance_glm = @group_loan.active_group_loan_memberships[0] 
    @second_premature_clearance_glm = @group_loan.active_group_loan_memberships[1] 
    @third_premature_clearance_glm = @group_loan.active_group_loan_memberships[2] 
  end
  
  
  it 'should confirm the first group_loan_weekly_collection' do
    @first_group_loan_weekly_collection.is_collected.should be_truthy 
    @first_group_loan_weekly_collection.is_confirmed.should be_truthy 
  end
  
  
  
  it 'can only be created if the weekly_collection is not collected and confirmed' do
    
    @first_gl_pc = GroupLoanPrematureClearancePayment.create_object({
      :group_loan_id => @group_loan.id,
      :group_loan_membership_id => @premature_clearance_glm.id ,
      :group_loan_weekly_collection_id => @first_group_loan_weekly_collection.id   
    })
    
    @first_gl_pc.errors.size.should_not == 0 
    
    
    @second_group_loan_weekly_collection.collect(
      {
        :collected_at => DateTime.now 
      }
    )
    @first_gl_pc = GroupLoanPrematureClearancePayment.create_object({
      :group_loan_id => @group_loan.id,
      :group_loan_membership_id => @premature_clearance_glm.id ,
      :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id   
    })
    
    @first_gl_pc.errors.size.should_not == 0 
  end
  
  it 'can only be created if the weekly collection is the first uncollected' do
     @first_gl_pc = GroupLoanPrematureClearancePayment.create_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @premature_clearance_glm.id ,
        :group_loan_weekly_collection_id => @third_group_loan_weekly_collection.id   
      })
      
      @first_gl_pc.errors.size.should_not == 0
      
  end
  
  it 'should confirm weekly_collection' do
    @first_group_loan_weekly_collection.errors.messages.each {|x| puts  "Msg: #{x}"}
    @first_group_loan_weekly_collection.is_confirmed.should be_truthy 
  end
  
  it 'should create compulsory savings for each member' do
    # total_compulsory_savings = BigDecimal('0')
    @group_loan.reload 
    @group_loan.group_loan_memberships.joins(:group_loan_product).each do |glm|
      glm.total_compulsory_savings.should == glm.group_loan_product.compulsory_savings
      # total_compulsory_savings += glm.group_loan_product.compulsory_savings
    end
    
    
  end
  
  
  
  context "perform premature clearance" do
    before(:each) do
      @initial_weekly_collection_amount_receivable = @second_group_loan_weekly_collection.amount_receivable
      @first_gl_pc = GroupLoanPrematureClearancePayment.create_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @premature_clearance_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id   
      })
      @second_group_loan_weekly_collection.reload 
      
      @second_group_loan_weekly_collection.collect(
         {
           :collected_at => DateTime.now 
         }
       )
       
       @second_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now) 
       @premature_clearance_glm.reload 
       @first_gl_pc.reload
       @second_group_loan_weekly_collection.reload
    end
    
    it "should confirm weekly collection" do
      @second_group_loan_weekly_collection.is_confirmed.should be_truthy
    end
    
    it "should create no deposit" do
      TransactionData.where(
        :transaction_source_id => @first_gl_pc.id , 
        :transaction_source_type => @first_gl_pc.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_premature_clearance_deposit],
      ).count.should == 0 
    end
    
    it "should create premature payment" do
      TransactionData.where(
        :transaction_source_id => @first_gl_pc.id , 
        :transaction_source_type => @first_gl_pc.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_premature_clearance_remaining_weeks_payment],
      ).count.should == 1
    end
    
    context "unconfirm group loan weekly collection" do
      before(:each) do
        @second_group_loan_weekly_collection.unconfirm 
        @second_group_loan_weekly_collection.reload
        @second_group_loan_weekly_collection.is_confirmed.should be_falsy 
        TransactionData.where(
          :transaction_source_id => @first_gl_pc.id , 
          :transaction_source_type => @first_gl_pc.class.to_s ,
          :code => TRANSACTION_DATA_CODE[:group_loan_premature_clearance_remaining_weeks_payment],
          :is_contra_transaction => true 
        ).order("id DESC").count.should == 1
        
      end
    end
    
    
  
  end
end

