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
    @group_loan.start(:started_at =>@started_at)
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
    @closed_at = DateTime.new(2013,12,5,0,0,0)
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
      
      # @initial_group_loan_run_away_amount_receivable = @group_loan.run_away_amount_receivable
      
      @run_away_member.mark_as_run_away(:run_away_at => DateTime.now)
      @group_loan.reload 
      @run_away_glm.reload 
      @second_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[1]
      @third_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[2]
    end
     
    
    
    # it 'should increase the group_loan run_away_amount_receivable' do
    #   @final_group_loan_run_away_amount_receivable = @group_loan.run_away_amount_receivable
    #   diff = @final_group_loan_run_away_amount_receivable - @initial_group_loan_run_away_amount_receivable
    #   diff.should == @run_away_glm.run_away_remaining_group_loan_payment
    # end
        
    context "pay at the same week run_away_receivable" do
      before(:each) do
        @gl_rar = @run_away_glm.group_loan_run_away_receivable 
        @gl_rar.set_payment_case({
          :payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]
        })
      end
      
      it 'should have weekly payment case' do
        @gl_rar.payment_case.should == GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]
      end
      
      it 'should produce amount receivable == all sum of weekly_payment_amount' do
        amount = BigDecimal('0')
        @group_loan.group_loan_memberships.joins(:group_loan_product).each do |glm|
          amount += glm.group_loan_product.weekly_payment_amount
        end
        
        amount.should == @first_group_loan_weekly_collection.amount_receivable
      end
 
      it 'should NOT reduce the amount receivable(same from collection#1)' do
        @first_collection_amount  = @first_group_loan_weekly_collection.amount_receivable
        @second_collection_amount = @second_group_loan_weekly_collection.amount_receivable

        diff = @first_collection_amount - @second_collection_amount
        diff.should == BigDecimal('0')
      end
      
      context "made 1 payment (weekly) including the member run away" do
        before(:each) do
          
          # @initial_run_away_amount_received = @group_loan.run_away_amount_received
          @second_group_loan_weekly_collection.collect(:collected_at => DateTime.now)
          @second_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now)
          
        
          @group_loan.reload
          @group_loan.close(:closed_at => @closed_at)
          @group_loan.reload
          @second_group_loan_weekly_collection.reload 
          @first_group_loan_weekly_collection.reload
          @gl_rar.reload 
        end
        
        it 'should preserve the amount_receivable in week 1,2,3' do
          expected_amount = BigDecimal('0')
          @group_loan.group_loan_memberships.each do |glm|
            expected_amount += glm.group_loan_product.weekly_payment_amount
          end
          
          @first_group_loan_weekly_collection.reload
          @second_group_loan_weekly_collection.reload
          @third_group_loan_weekly_collection.reload
          
          @first_group_loan_weekly_collection.amount_receivable.should == expected_amount
          @second_group_loan_weekly_collection.amount_receivable.should == expected_amount
          @third_group_loan_weekly_collection.amount_receivable.should == expected_amount
        end
        
        it 'should not close group loan' do
          @group_loan.errors.size.should_not ==0 
          @group_loan.is_closed.should be_falsey 
        end
         
      
        
        it "can't change payment case  after a payment has been made" do
          @gl_rar.set_payment_case({
            :payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]
          })
          
          @gl_rar.errors.size.should_not == 0 
          
          @gl_rar.reload 
          @gl_rar.set_payment_case({
            :payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]
          })
          
          @gl_rar.errors.size.should_not == 0
        end
      end
      
      context "perform all remaining collection" do
        before(:each) do
          @group_loan.group_loan_weekly_collections.order("id ASC").each do |x|
            next if x.is_collected? and x.is_confirmed? 
            x.collect(:collected_at => DateTime.now)
            x.confirm(:confirmed_at => DateTime.now)
          end
      
          @group_loan.reload
          @group_loan.close(:closed_at => @closed_at)
          @group_loan.reload
        end
        
        it 'should close the group loan' do
          @group_loan.is_closed.should be_truthy 
        end
        
        it 'should return compulsory savings per normal' do
          normal_total_compulsory_savings = BigDecimal('0')
          
          weekly_compulsory_savings_increment = BigDecimal('0')
          
          @group_loan.group_loan_memberships.joins(:group_loan_product).each do |glm|
            weekly_compulsory_savings_increment += glm.group_loan_product.compulsory_savings 
          end
          
          normal_total_compulsory_savings = weekly_compulsory_savings_increment*@group_loan.loan_duration 
          
         
          
          diff =  BigDecimal('0')
          
          # puts "\n\n========\n"
          # puts "total compulsory savings: #{@group_loan.total_compulsory_savings}"
          # puts "remaining premature_clearance : #{@group_loan.remaining_premature_clearance_deposit}"
          # puts "bad_debt allowance : #{@group_loan.bad_debt_allowance}"
          # puts "===========>\n"
          # puts "normal_compulsory-savings = #{normal_total_compulsory_savings} "
          # puts "compulsory_savings-return amount: #{@group_loan.compulsory_savings_return_amount}"
                  
          (normal_total_compulsory_savings - @group_loan.total_compulsory_savings_pre_closure).should == diff
        end
        
        it 'should confirm all group loan weekly collections' do
          @group_loan.group_loan_weekly_collections.order("id ASC").each do |x|
            x.is_collected.should be_truthy 
            x.is_confirmed.should be_truthy 
          end
        end
        
        # it 'should create (total_weeks - 1) run_away_receivable_payment' do
        #   @gl_rar.group_loan_run_away_receivable_payments.count.should == ( @group_loan.number_of_collections - 1 )
        # end
        
        # it 'should complete the  run_away_amount_receivable' do 
        #   @group_loan.run_away_amount_received.should == @group_loan.run_away_amount_receivable 
        # end
      end

    end
    
  end
  
  
  
   
  
end

