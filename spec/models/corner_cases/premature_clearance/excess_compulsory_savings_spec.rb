# Case 1: member pass away mid shite 

=begin
1. Handle the Premature Clearance case: if there is excess compulsory savings
    Premature Clearance amount payable == principal * remaining weeks - compulsory savings available
    
    If there is excess compulsory savings after deduction by principal * remaining weeks, 
    the compulsory savings will be ported to savings_account 
    
=> Spec setup: we create a special group_loan_product with principal == compulsory savings

it means that if the member declares premature clearance at week > loan_duration/2,
  there will be excess compulsory savings => will be ported to savings_account 
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
    @principal_1          = BigDecimal('4000')
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
    @principal_2          = BigDecimal('4000')
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
    @fifth_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[4] 
    @sixth_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[5] 
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
   
  
  context "perform weekly collection per normal" do
    before(:each) do
      @group_loan.group_loan_weekly_collections.order("id ASC").each do |x|
        next if x.is_collected? and x.is_confirmed? 
        break if x.id == @sixth_group_loan_weekly_collection.id 
        x.collect(:collected_at => DateTime.now)
        x.confirm(:confirmed_at => DateTime.now )
      end
      
      @group_loan.reload 
      @premature_clearance_glm.reload 
    end
    
    it "should confirm week 5" do
      @fifth_group_loan_weekly_collection.reload
      @fifth_group_loan_weekly_collection.is_confirmed.should be_truthy 
    end
      
    it 'should have more compulsory savings than remaining principal' do
      remaining_week = @group_loan.loan_duration - @sixth_group_loan_weekly_collection.week_number   
      
      remaining_principal_amount =  remaining_week * @premature_clearance_glm.group_loan_product.principal 
      
      @premature_clearance_glm.total_compulsory_savings.should > remaining_principal_amount
    end
      
  
      
    context "perform premature clearance" do
      before(:each) do
        @initial_weekly_collection_amount_receivable = @sixth_group_loan_weekly_collection.amount_receivable
        puts "initial_weekly_amount_receivable: #{@initial_weekly_collection_amount_receivable.to_s}"
        @first_gl_pc = GroupLoanPrematureClearancePayment.create_object({
          :group_loan_id => @group_loan.id,
          :group_loan_membership_id => @premature_clearance_glm.id ,
          :group_loan_weekly_collection_id => @sixth_group_loan_weekly_collection.id   
          })
        @sixth_group_loan_weekly_collection.reload
        @premature_clearance_glm.reload 
        @fifth_group_loan_weekly_collection.reload
        puts "The weekly amount_receivable of week 5: #{@fifth_group_loan_weekly_collection.amount_receivable.to_s}"
        puts "The premature_clearance_weekly_payment: #{@premature_clearance_glm.group_loan_product.weekly_payment_amount.to_s}"
      end
        
      
      it 'should produce amount receivable per normal' do
        # puts "awesome bitch"
        # since there is more compulsory savings than payable 
        expected_amount = BigDecimal('0')
        @group_loan.group_loan_memberships.each do |glm|
          expected_amount += glm.group_loan_product.weekly_payment_amount 
        end
        puts "expected_amount = #{expected_amount.to_s}"
        puts "actual: #{@sixth_group_loan_weekly_collection.amount_receivable.to_s}"
        
        remaining_week = @group_loan.number_of_collections - @sixth_group_loan_weekly_collection.week_number
        @sixth_group_loan_weekly_collection.amount_receivable.should == expected_amount + 
                          remaining_week*@premature_clearance_glm.group_loan_product.weekly_payment_amount
      end
      
      
      
      context 'confirm weekly collection' do
        before(:each) do
          @initial_compulsory_savings =  @premature_clearance_glm.total_compulsory_savings 
          @initial_savings_account_amount = @premature_clearance_glm.member.total_savings_account
          @sixth_group_loan_weekly_collection.collect(:collected_at => DateTime.now)
          @sixth_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now )
          @premature_clearance_glm.reload
        end
        
        it 'should NOT empty out the compulsory savings' do
          @premature_clearance_glm.total_compulsory_savings.should_not == BigDecimal("0")
        end
        
        it 'should increase savings_account amount' do
          @final_savings_account_amount = @premature_clearance_glm.member.total_savings_account
          
          diff = BigDecimal("0")
        end
        
        it 'should create 1 savings_entry: compulsory savings ADDITION' do
          @first_gl_pc.savings_entries.count.should == 1    
          first_savings_entries = @first_gl_pc.savings_entries.first
          
          first_savings_entries.savings_status.should == SAVINGS_STATUS[:group_loan_compulsory_savings]
        end
      end
         
   
    end
  end
end

