# Case 1: member deceased mid shite 

# WE HAVE A PROBLEM: what if there is uncollectible payment.. and member deceased.. the group
# has to pay for the uncollectible 

=begin
1. Handle the Deceased Case
     Branch Submit the form (written + double signed by Loan Officer + Branch Manager ), so that it will be deactivated by the central command. 

     Then, the weekly payment can be done (excluding the deceased member).

     1. Mark member as deceased
       it will deactivate all financial product membership
       
    2. For each financial product deactivated, it will post bad debt allowance  + 1 Deceased Clearance
    
    3. Then, it is admin's job to mark the deceased clearance as insurance claimable or directly
        write off as bad debt expense 
        
    4. If it is written off as bad debt expense: click "Write Off Allowance"
    
    5. If it is claimable from insurance: click
        "Insurance Claimable" : specify the amount to be returned by insurance: principal + donation
        
        On InsuranceClaimable submit : will make journal posting to 
        1. cancel the bad debt allowance
        2. add account receivable: donation + principal return 
        
        
    6. For the claimable deceased_clearance: 
      Click "Insurance Claim Received"  => will add $$ to BRI account. 
      
    7. For claimable deceased_clearance:
      Click "Distribute Donation"  => will give out $$ to member.. deduct from main cash account. 
        
        
       
       
      
          
          
          
         

=end

require 'spec_helper'

describe DeceasedClearance do
  
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
    @closed_at = DateTime.new(2013,12,5,0,0,0)
    
    # start group loan 
    @group_loan.start(:started_at => @started_at )
    @group_loan.reload

    # disburse loan 
    @group_loan.disburse_loan(:disbursed_at => @disbursed_at)
    @group_loan.reload
    
    @first_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC").first
    @first_group_loan_weekly_collection.should be_valid 
    @first_group_loan_weekly_collection.collect(
      {
        :collected_at => DateTime.now 
      }
    )

    @first_group_loan_weekly_collection.is_collected.should be_truthy
    @first_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now )
    @first_group_loan_weekly_collection.reload
    
  end
  
  
  it 'should confirm the first group_loan_weekly_collection' do
    @first_group_loan_weekly_collection.is_collected.should be_truthy 
    @first_group_loan_weekly_collection.is_confirmed.should be_truthy 
  end
  
   
  context "a member is passed away ( week 2 ) "  do
    before(:each) do
       
      @deceased_glm = @group_loan.active_group_loan_memberships.first 
      @deceased_glm.reload
      @deceased_member = @deceased_glm.member 
      @initial_active_glm_count = @group_loan.active_group_loan_memberships.count 
      @first_week_amount_receivable=   @first_group_loan_weekly_collection.amount_receivable

      @initial_savings_account = @deceased_member.total_savings_account
      @initial_compulsory_savings = @deceased_glm.total_compulsory_savings
      @deceased_member.mark_as_deceased(:deceased_at => DateTime.now )
      @group_loan.reload 
      @deceased_glm.reload 
      @second_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[1]
      @deceased_member.reload 
    end
    
    it 'should create one DeceasedPrincipalReceivable' do
      DeceasedClearance.count.should == 1 
      dc = DeceasedClearance.first 
      
      @deceased_glm.reload 
      # dpr.week_number.should == @second_group_loan_weekly_collection.week_number 
      @deceased_glm.is_active.should be_falsey 
      @deceased_glm.deactivation_week_number.should == @second_group_loan_weekly_collection.week_number
      @deceased_glm.deactivation_case.should == GROUP_LOAN_DEACTIVATION_CASE[:deceased]
    end
    
    it "should create on DeceasedClearance" do 
      DeceasedClearance.where(
        :financial_product_id => @group_loan.id,
        :financial_product_type => @group_loan.class.to_s, 
        :member_id => @deceased_member.id
      ).count.should == 1 
      
      deceased_clearance = DeceasedClearance.where(
        :financial_product_id => @group_loan.id,
        :financial_product_type => @group_loan.class.to_s, 
        :member_id => @deceased_member.id
      ).first 
      
      TransactionData.where(
        :transaction_source_id =>deceased_clearance.id ,
        :transaction_source_type => deceased_clearance.class.to_s,
        :is_confirmed => true 
      ).count.should == 1 
    end
    
     
  end
end

