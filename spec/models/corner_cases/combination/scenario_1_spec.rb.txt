# Scenario 1: multiple Premature clearances happening on a given week

=begin

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
      
      @second_gl_pc = GroupLoanPrematureClearancePayment.create_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @second_premature_clearance_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id   
      })
      
      
      @second_group_loan_weekly_collection.reload 
    end
    
    
   
    
    it 'should increase the amount receivable in the group_loan_weekly_collection' do
      final = @second_group_loan_weekly_collection.amount_receivable 
      diff = final - @initial_weekly_collection_amount_receivable
      diff.should == @first_gl_pc.amount + @second_gl_pc.amount 
    end
    
    it 'shoud allow deletion if the weekly_collection has not been confirmed' do
      @first_gl_pc.delete_object
      @first_gl_pc.persisted?.should be_falsey 
    end
    
    
    
    it 'should produce weekly_collection with 2 premature clearance' do
      @second_group_loan_weekly_collection.group_loan_premature_clearance_payments.count.should == 2 
    end
    
    it 'should produce correct premature clearance amount (premature clearance 1)' do
      @second_group_loan_weekly_collection.is_confirmed.should be_falsey 
      
      # puts "compulsory_savings weekly: #{@premature_clearance_glm.group_loan_product.compulsory_savings}"
      # puts "total_compulsory_savings: #{@premature_clearance_glm.total_compulsory_savings}"
      
      remaining_week = @group_loan.loan_duration - @second_group_loan_weekly_collection.week_number  
      remaining_principal_amount = @premature_clearance_glm.group_loan_product.principal * remaining_week
      
      number_of_weeks_paid = @second_group_loan_weekly_collection.week_number  - 1
      total_compulsory_savings = @premature_clearance_glm.group_loan_product.compulsory_savings * number_of_weeks_paid
      
      total_compulsory_savings.should == @premature_clearance_glm.total_compulsory_savings
      
    
      current_week_compulsory_savings = @premature_clearance_glm.group_loan_product.compulsory_savings
      
      @first_gl_pc.amount.should == remaining_principal_amount - 
                      @premature_clearance_glm.total_compulsory_savings -   # the total compulsory savings hasn't included the current weel
                      current_week_compulsory_savings
    end
    
    it 'should produce correct premature clearance amount (premature clearance 2)' do
      @second_group_loan_weekly_collection.is_confirmed.should be_falsey 
      
      # puts "compulsory_savings weekly: #{@premature_clearance_glm.group_loan_product.compulsory_savings}"
      # puts "total_compulsory_savings: #{@premature_clearance_glm.total_compulsory_savings}"
      
      remaining_week = @group_loan.loan_duration - @second_group_loan_weekly_collection.week_number  
      remaining_principal_amount = @second_premature_clearance_glm.group_loan_product.principal * remaining_week
      
      number_of_weeks_paid = @second_group_loan_weekly_collection.week_number  - 1
      total_compulsory_savings = @second_premature_clearance_glm.group_loan_product.compulsory_savings * number_of_weeks_paid
      
      total_compulsory_savings.should == @second_premature_clearance_glm.total_compulsory_savings
      
    
      current_week_compulsory_savings = @second_premature_clearance_glm.group_loan_product.compulsory_savings
      
      @second_gl_pc.amount.should == remaining_principal_amount - 
                      @second_premature_clearance_glm.total_compulsory_savings -   # the total compulsory savings hasn't included the current weel
                      current_week_compulsory_savings
    end
    
    it 'should produce correct second_group_loan_weekly_collection.amount_receivable' do
      expected_amount  = BigDecimal('0')
      @group_loan.group_loan_memberships.each do |glm|
        expected_amount += glm.group_loan_product.weekly_payment_amount 
      end
      
      
      # add the premature clearance_1 + clearance_2 
      expected_amount += @second_gl_pc.amount + @first_gl_pc.amount 
      
       
      
      
      @second_group_loan_weekly_collection.amount_receivable.should == expected_amount 
    end
    
       
    
    context "weekly_collection.confirm" do
      before(:each) do
        @second_group_loan_weekly_collection.collect(
          {
            :collected_at => DateTime.now 
          }
        )
        
        @second_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now) 
        @premature_clearance_glm.reload 
        @second_premature_clearance_glm.reload 
        @first_gl_pc.reload 
        @second_gl_pc.reload 
      end
      
      it 'should confirm the clearance' do
        @first_gl_pc.is_confirmed.should be_truthy 
        @second_gl_pc.is_confirmed.should be_truthy 
      end
      
      it 'should deactivate the membership' do
        @premature_clearance_glm.is_active.should be_falsey
        @premature_clearance_glm.deactivation_case.should == GROUP_LOAN_DEACTIVATION_CASE[:premature_clearance]
        @premature_clearance_glm.deactivation_week_number.should == @second_group_loan_weekly_collection.week_number + 1 
        
        @second_premature_clearance_glm.is_active.should be_falsey
        @second_premature_clearance_glm.deactivation_case.should == GROUP_LOAN_DEACTIVATION_CASE[:premature_clearance]
        @second_premature_clearance_glm.deactivation_week_number.should == @second_group_loan_weekly_collection.week_number + 1
      end
      
      it 'should increase the amount_receivable in week 2 by premature_clearance amount' do
        remaining_week = @group_loan.loan_duration - @premature_clearance_glm.deactivation_week_number + 1 
        premature_clearance_amount = @first_gl_pc.amount + @second_gl_pc.amount 
         
        base_collection = BigDecimal('0')
        @group_loan.group_loan_memberships.each do |glm|
          base_collection += glm.group_loan_product.weekly_payment_amount 
        end
        @second_group_loan_weekly_collection.amount_receivable.should == base_collection + premature_clearance_amount 
      end
      
      it 'should reduce the amount_receivable in week 3' do
        base_collection = BigDecimal('0')
        @group_loan.group_loan_memberships.each do |glm|
          next if glm.id == @premature_clearance_glm.id 
          next if glm.id == @second_premature_clearance_glm.id 
          base_collection += glm.group_loan_product.weekly_payment_amount 
        end
        @third_group_loan_weekly_collection.amount_receivable.should == base_collection 
      end
      
      context "closing the group loan" do
        before(:each) do
          @group_loan.reload 
          @group_loan.group_loan_weekly_collections.order("id ASC").each do |x|
            next if x.is_collected? and x.is_confirmed? 
            x.collect(:collected_at => DateTime.now)
            x.confirm(:confirmed_at => DateTime.now)
          end
          
          @group_loan.reload
          @group_loan.close(:closed_at => @closed_at)
        end
        
        it 'should not have compulsory_savings on premature_clearance' do
          @premature_clearance_glm.total_compulsory_savings.should == BigDecimal('0')
          @second_premature_clearance_glm.total_compulsory_savings.should == BigDecimal('0')
        end
        
        it 'should return the correct compulsory saving amount: not including the premature clearance' do
          @group_loan.is_closed.should be_truthy 
          expected_amount = BigDecimal('0')
          @group_loan.group_loan_memberships.each do |glm|
            next if glm.id == @premature_clearance_glm.id 
            next if glm.id == @second_premature_clearance_glm.id 
            expected_amount += glm.group_loan_product.compulsory_savings
          end
          @group_loan.compulsory_savings_return_amount.should == expected_amount*@group_loan.loan_duration
        end
      
      end
       
    end
      
  
  end
end

