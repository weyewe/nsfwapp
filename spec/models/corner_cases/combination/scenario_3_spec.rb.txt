# Scenario 3:  run_away (weekly resolution) 			+ premature (different week) 

=begin
    week 2 : run_away weekly_collection
    week 5 : premature clearance
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
    @fourth_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[3]
    @fifth_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[4]
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
    @run_away_glm = @group_loan.active_group_loan_memberships[0] 
    @premature_clearance_glm = @group_loan.active_group_loan_memberships[1]  
  end
   
    
  
  
  
  context "perform run_away" do
    before(:each) do
      @initial_weekly_collection_amount_receivable = @second_group_loan_weekly_collection.amount_receivable
      @run_away_member =  @run_away_glm.member 
      @run_away_member.mark_as_run_away(:run_away_at => DateTime.now)
      
      @run_away_member.reload 
      @run_away_glm.reload 
      @second_group_loan_weekly_collection.reload 
      @gl_rar = @run_away_glm.group_loan_run_away_receivable
      @group_loan.reload 
    end
    
    it 'should create  valid gl_rar' do
      @gl_rar.should be_valid 
    end
    
    it 'should have weekly_resolution payment_case' do
      @gl_rar.payment_case.should == GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly] 
    end
    
    it 'should have no changes in amount_receivable' do
      expected_amount = BigDecimal('0')
      @group_loan.group_loan_memberships.each do |glm|
        expected_amount += glm.group_loan_product.weekly_payment_amount 
      end
      
      @second_group_loan_weekly_collection.amount_receivable.should == expected_amount
    end
    
    context "confirm second_week" do
      before(:each) do
        @second_group_loan_weekly_collection.collect(:collected_at => DateTime.now)
        @second_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now )
        
        @third_group_loan_weekly_collection.reload 
        @run_away_glm.reload
      end
      
      it 'should deactivate run_away_glm' do
        @run_away_glm.is_active.should be_falsey 
        @run_away_glm.deactivation_case.should == GROUP_LOAN_DEACTIVATION_CASE[:run_away]   
      end
      
      
      it 'should keep the amount receivable intact' do
        expected_amount = BigDecimal('0')
        @group_loan.group_loan_memberships.each do |glm|
          expected_amount += glm.group_loan_product.weekly_payment_amount 
        end
        
        @third_group_loan_weekly_collection.amount_receivable.should == expected_amount
      end
      
      context "confirm up to week 5: week 5 is not confirmed nor collected" do
        before(:each) do
          @group_loan.reload 
          
          @group_loan.group_loan_weekly_collections.order("week_number ASC").each do |weekly_collection|
            break if weekly_collection.week_number == 5 
            next if weekly_collection.is_collected? and  weekly_collection.is_confirmed? 
            weekly_collection.collect(
              :collected_at => DateTime.now
            )
            weekly_collection.confirm(
              :confirmed_at => DateTime.now
            )
            
            
          end
          @third_group_loan_weekly_collection.reload 
          @fourth_group_loan_weekly_collection.reload
          @fifth_group_loan_weekly_collection.reload 
          @group_loan.reload 
          
          @first_gl_pc = GroupLoanPrematureClearancePayment.create_object({
            :group_loan_id => @group_loan.id,
            :group_loan_membership_id => @premature_clearance_glm.id ,
            :group_loan_weekly_collection_id => @fifth_group_loan_weekly_collection.id   
          })
          
        end
        
        it "should confirm the third week" do
          @third_group_loan_weekly_collection.is_confirmed.should be_truthy 
          
          
        end
        
        
        it 'should confirm the fourth week' do
          @first_gl_pc.errors.messages.each {|x| puts x }
          
          @fourth_group_loan_weekly_collection.errors.messages.each {|x| puts "glwc error: #{x}" }
          @fourth_group_loan_weekly_collection.is_confirmed?.should be_truthy 
        end
        
        it 'should create valid gl_pc' do
          @first_gl_pc.should be_valid 
      
        end
        
        it 'should produce premature_clearance_payment including the bail_out for run_away member' do
          compulsory_savings = @premature_clearance_glm.group_loan_product.compulsory_savings 
          paid_weeks =   4
          remaining_weeks = @group_loan.loan_duration - ( paid_weeks + 1 ) 
          
          bail_out_amount = 
          @first_gl_pc.amount.should == GroupLoan.rounding_up( 
                  total_remaining_principal - 
                  compulsory_savings*(paid_weeks + 1) + 
                  bail_out_amount,
                  DEFAULT_PAYMENT_ROUND_UP_VALUE )
        end
        
        
        # /spec/models/corner_cases/uncollectible/end_of_cycle_resolution_spec.rb
       
      end
          
    
    end
  end
end

