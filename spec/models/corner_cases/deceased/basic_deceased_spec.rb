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

  it "should not allow to undo mark as deceased if the member is not deceased yet" do
    @deceased_glm = @group_loan.active_group_loan_memberships.first 
    @deceased_member = @deceased_glm.member 
    @deceased_member.undo_mark_as_deceased

    @deceased_member.errors.size.should_not == 0 
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

    context "unconfirm deceased" do
      before(:each) do


        @dc = DeceasedClearance.first 
        @dc_id = @dc.id
        @dc_class = @dc.class.to_s
        @member  = @deceased_glm.member
        @member.reload
        @member.undo_mark_as_deceased

        

      end

      it "should produce no error" do
        @member.errors.size.should == 0 
        @member.is_deceased.should be_falsey
      end

      it "should create contra transaction" do

        

        ta = TransactionData.where({

        :transaction_source_id => @dc_id , 
        :transaction_source_type => @dc_class ,
        :code => TRANSACTION_DATA_CODE[:group_loan_deceased_declaration],
        :is_contra_transaction => true 
        }).order("id DESC").first

        ta.should be_valid
        ta.is_confirmed.should be_truthy
      end
    end
    
    it 'should extract the glm that is active at that particular week' do
      week_2_active_glm_count = @second_group_loan_weekly_collection.active_group_loan_memberships.count 
      week_2_active_glm_count.should == (@initial_active_glm_count - 1 ) 
    end
    
    it 'should create diff from first week amount receivable' do
      diff = @first_week_amount_receivable -  @second_group_loan_weekly_collection.amount_receivable
      diff.should  == @deceased_glm.group_loan_product.weekly_payment_amount
    end
    
    it 'should preserve the active glm in week 1 (including the deceased in week 2)' do 
      active_glm_id_list = @first_group_loan_weekly_collection.active_group_loan_memberships.map {|x| x.id }
      active_glm_id_list.count.should == @initial_active_glm_count 
    end
    
    
    it 'should reduce the amount receivable(different from collection#1)' do 
      @first_collection_amount  = @first_group_loan_weekly_collection.amount_receivable
      @second_collection_amount = @second_group_loan_weekly_collection.amount_receivable
      
      diff = @first_collection_amount - @second_collection_amount
      diff.should == @deceased_glm.group_loan_product.weekly_payment_amount
    end
    
    it 'should reduce the active_glm count' do
      @final_active_glm_count = @group_loan.active_group_loan_memberships.count
      diff = @initial_active_glm_count - @final_active_glm_count
      diff.should == 1 
    end
    
    it 'should not contain the deceased glm in the active_glm' do 
      @active_glm_id_list = @group_loan.active_group_loan_memberships.map{|x| x.id }
      @active_glm_id_list.include?(@deceased_glm.id).should be_falsey 
    end
    
    it 'should only create 1 group_loan_weekly_payment for deceased_glm' do
      @deceased_glm.group_loan_weekly_payments.count.should == 1 
    end
    
    it 'should NOT empty out the compulsory savings, ported to savings account' do
      
      @deceased_glm.total_compulsory_savings.should_not == BigDecimal('0')
    end
    
    it 'should increase the savings_account according to the flushed out savings account' do
      # @initial_savings_account = @deceased_member.total_savings_account
      # @initial_compulsory_savings = @deceased_glm.total_compulsory_savings
      # @deceased_member.reload 
      
      @final_savings_account = @deceased_member.total_savings_account
      @final_compulsory_savings = @deceased_glm.total_compulsory_savings
      
      diff_savings_account = @final_savings_account - @initial_savings_account
      diff_savings_account.should == BigDecimal('0')
      
      @final_compulsory_savings.should_not == BigDecimal('0')
    end
    
    it 'should not introduce bad debt ' do
      @group_loan.reload
      @group_loan.bad_debt_allowance.should == BigDecimal('0')
    end


    context "perform collection and confirmation" do
      before(:each) do
        @second_group_loan_weekly_collection.collect(:collected_at => DateTime.now)
        @second_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now )
      end
      
      it 'should not create GroupLoanWeeklyPayment to the deceased member' do
        GroupLoanWeeklyPayment.where(:group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id,
                :group_loan_membership_id => @deceased_glm.id ).count.should == 0 
      end

      it "should not be allowed to undo deceased clearance" do
        @deceased_member.reload
        @deceased_member.undo_mark_as_deceased
        @deceased_member.errors.size.should_not == 0
      end

      it "should be allowed to undo deceased clearance if collection is undoo" do
        @second_group_loan_weekly_collection.unconfirm
        @second_group_loan_weekly_collection.uncollect

        @deceased_member.reload

        @deceased_member.undo_mark_as_deceased
        @deceased_member.errors.size.should == 0 

        @deceased_member.reload
        
        @deceased_member.is_deceased.should be_falsey
        @deceased_member.deceased_at.should be_nil

        @deceased_member.group_loan_memberships.each do |x|
          x.is_active.should be_truthy
        end


      end
    end
     
    
    context "finishing the payment collection cycle" do
      before(:each) do
        @group_loan.group_loan_weekly_collections.order("id ASC").each do |x|
          next if x.is_collected? and x.is_confirmed? 
          
          x.collect(:collected_at => DateTime.now)
          x.confirm(:confirmed_at => DateTime.now )
        end
        
        @group_loan.reload
        @group_loan.close(:closed_at => @closed_at )
        @group_loan.reload
        @second_group_loan_weekly_collection.reload 
        @first_group_loan_weekly_collection.reload 
      end
      
      it 'should close the group loan' do
         @group_loan.is_closed.should be_truthy 
       end
      
      it 'should give the correct number of active group_loan_membership (though it is closed)' do
        @group_loan.active_group_loan_memberships.count.should == @initial_active_glm_count -1 # (1 deceased)
        @group_loan.group_loan_memberships.where(:is_active => true).count.should == 0 
        
        week_2_active_glm_count = @second_group_loan_weekly_collection.active_group_loan_memberships.count 
        week_2_active_glm_count.should == ( @initial_active_glm_count - 1 )
        
        week_1_active_glm_count = @first_group_loan_weekly_collection.active_group_loan_memberships.count 
        week_1_active_glm_count.should == ( @initial_active_glm_count )
      end
      
      it 'should return the compulsory savings, not including the deceased member' do
        expected_amount = BigDecimal('0')
        @group_loan.group_loan_memberships.each do |x|
          next if x.id == @deceased_glm.id  
          expected_amount += x.group_loan_product.compulsory_savings
        end
        
        @group_loan.total_compulsory_savings_pre_closure.should == expected_amount*@group_loan.loan_duration + @deceased_glm.total_compulsory_savings
      end
    end

  end
end

