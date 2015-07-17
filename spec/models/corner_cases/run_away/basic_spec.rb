# Case 1: member run away mid-cycle 

=begin
1. Handle the Run Away case
     Branch Submit the form (written + double signed by Loan Officer + Branch Manager ), 
      so that it will be deactivated by the central command.  
      => the runaway member will be blocked from all group loan product 

     For each GroupLoanProduct that are currently active, the branch
     has to submit the payment decision: whether default resolved weekly, or and the end-of-cycle

     1. Weekly
        There is extra payment to be made (total = all active members + run away member)
        In the payment details: list all active member's payment + entry for the run away member. 
        That's it.  => compose reports 


     2. End of cycle
          In the weekly payment, ignore the extra payment caused by the run away member
          At the end of the cycle, deduct all active's compulsory savings by the amount debted.  
          
          If there is excess, 

=end

require 'spec_helper'

describe GroupLoan do
  
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
  
  context "a member  run away ( week 2 ) "  do
    before(:each) do
      @run_away_glm = @group_loan.active_group_loan_memberships.first 
      @run_away_member = @run_away_glm.member 
      @initial_active_glm_count = @group_loan.active_group_loan_memberships.count 
      @first_week_amount_receivable=   @first_group_loan_weekly_collection.amount_receivable
      
      @run_away_member.mark_as_run_away(:run_away_at => DateTime.now)
      @group_loan.reload 
      @run_away_glm.reload 
      @second_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[1]
    end
    
    it 'should create one deactivated glm' do
      
      
      @run_away_glm.reload 
      @run_away_glm.is_active.should be_falsey 
      @run_away_glm.deactivation_week_number.should == @second_group_loan_weekly_collection.week_number
      @run_away_glm.deactivation_case.should == GROUP_LOAN_DEACTIVATION_CASE[:run_away]
    end
    
    it 'should create 1 group_loan_run_away_receivable, by default weekly payment' do
      GroupLoanRunAwayReceivable.count.should == 1 
      a = GroupLoanRunAwayReceivable.first 
      # by default, weekly 
      a.payment_case.should == GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]
      
      a.group_loan_membership_id.should == @run_away_glm.id 
      @run_away_glm.group_loan_run_away_receivable.should be_valid 
      @run_away_glm.group_loan_run_away_receivable.id.should == GroupLoanRunAwayReceivable.first.id 
    end
    
    it 'should extract the glm that is active at that particular week' do
      week_2_active_glm_count = @second_group_loan_weekly_collection.active_group_loan_memberships.count 
      week_2_active_glm_count.should == (@initial_active_glm_count - 1 ) 
    end
    
    it 'should reduce the active_glm count' do
      @final_active_glm_count = @group_loan.active_group_loan_memberships.count
      diff = @initial_active_glm_count - @final_active_glm_count
      diff.should == 1 
    end
    
    it 'should not contain the run away glm in the active_glm' do 
      @active_glm_id_list = @group_loan.active_group_loan_memberships.map{|x| x.id }
      @active_glm_id_list.include?(@run_away_glm.id).should be_falsey 
    end
    
    it 'should be allowed to change payment case' do
      @gl_rar = @run_away_glm.group_loan_run_away_receivable 
      @gl_rar.set_payment_case({
        :payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]
      })
      @gl_rar.payment_case.should ==  GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]
      
      @gl_rar.set_payment_case({
        :payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]
      })
      @gl_rar.payment_case.should ==  GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]
    end
    
    
  end
  
  
  
   
  
end

