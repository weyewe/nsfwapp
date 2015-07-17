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
  
  it 'should not create uncollectible_weekly_payment for the confirmed week' do
    @gl_wu = GroupLoanWeeklyUncollectible.create_object({
      :group_loan_id => @group_loan.id,
      :group_loan_membership_id => @uncollectible_glm.id ,
      :group_loan_weekly_collection_id => @first_group_loan_weekly_collection.id  ,
      :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
    })
    
    @gl_wu.should_not be_valid
  end
  
  it 'should not create double uncollectible weekly payment' do
    @gl_wu =GroupLoanWeeklyUncollectible.create_object({
      :group_loan_id => @group_loan.id,
      :group_loan_membership_id => @uncollectible_glm.id ,
      :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id ,
      :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle] 
    })
    
    @gl_wu.should be_valid
    
    @gl_wu =GroupLoanWeeklyUncollectible.create_object({
      :group_loan_id => @group_loan.id,
      :group_loan_membership_id => @uncollectible_glm.id ,
      :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id  ,
      :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
    })
    
    @gl_wu.should_not  be_valid
  end
  
  it 'should not create uncollectible_weekly_payment for the non first uncollected week' do
    @gl_wu = GroupLoanWeeklyUncollectible.create_object({
      :group_loan_id => @group_loan.id,
      :group_loan_membership_id => @uncollectible_glm.id ,
      :group_loan_weekly_collection_id => @third_group_loan_weekly_collection.id  ,
      :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
    })
    
    @gl_wu.should_not be_valid
  end
  
  context "updating the uncollectible's glm id" do
    before(:each) do
      @first_gl_wu = GroupLoanWeeklyUncollectible.create_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @uncollectible_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id,
        :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]   
      })
      
      @second_gl_wu = GroupLoanWeeklyUncollectible.create_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @second_uncollectible_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id  ,
        :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
      })
    end
    
    it 'should create first_gl_wu and second_gl_wu ' do
      @first_gl_wu.should be_valid 
      @second_gl_wu.should be_valid 
    end
    
    it 'should allow update to the second_gl_wu' do
      @second_gl_wu.update_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @third_uncollectible_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id ,
        :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
      })
      
      @second_gl_wu.should be_valid 
       
       
      @second_gl_wu.group_loan_membership.id.should == @third_uncollectible_glm.id
    end
    
    it 'should not allow update to the first_gl_wu (create 2 uncollectibles with equal glm_id)' do
      @second_gl_wu.update_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @uncollectible_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id ,
        :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
      })
      
      @second_gl_wu.should_not be_valid 
    end
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
    end
    
    it 'should not change group loan bad_debt_allowance ' do
      final_bad_debt_allowance = @group_loan.bad_debt_allowance
      diff = final_bad_debt_allowance - @initial_bad_debt_allowance
      diff.should == BigDecimal('0')
    end
    
    it 'should produce 0 for the initial_uncollectible_payment_amount' do
      @initial_extract_uncollectible_weekly_payment_amount.should == BigDecimal('0')
    end
    
    it 'should create valid gl_wu' do
      @first_gl_wu.should be_valid 
    end
    
    it 'should reduce the weekly_collection amount' do
      final_amount_receivable = @second_group_loan_weekly_collection.amount_receivable
      diff = @initial_amount_receivable - final_amount_receivable
      diff.should == @uncollectible_glm.group_loan_product.weekly_payment_amount
    end
    
    # it 'should not update default_payment amount_receivable pre-weekly_collection confirmation'  
    
    it 'should be deletable' do
      @first_gl_wu.delete_object
      @first_gl_wu.persisted?.should be_falsey 
    end
     
    
    context "confirming the weekly_collection with group_loan_weekly_uncollectible" do
      before(:each) do
        
        # @initial_personal_bad_debt_allowance = @uncollectible_glm.personal_bad_debt_allowance
        @second_group_loan_weekly_collection.collect({
          :collected_at => DateTime.now 
        })
        
        @second_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now) 
        @group_loan.reload 
        @first_gl_wu.reload 
        @second_group_loan_weekly_collection.reload 
        
        @group_loan.reload 
      end
      
      it 'should NOT update the bad_debt_allowance amount by the uncollectible\'s principal' do
        # reason: uncollectible is personal's bad debt allowance
        @final_bad_debt_allowance = @group_loan.bad_debt_allowance
        diff = @final_bad_debt_allowance  - @initial_bad_debt_allowance
        diff.should == BigDecimal("0")  #@uncollectible_glm.group_loan_product.principal 
      end
      
      # it "should increase personal bad debt allowance" do
      #   @uncollectible_glm.reload 
      #   @final_personal_bad_debt_allowance = @uncollectible_glm.personal_bad_debt_allowance
      #   @initial_personal_bad_debt_allowance
      #   
      #   diff = @final_personal_bad_debt_allowance - @initial_personal_bad_debt_allowance
      #   diff.should == @uncollectible_glm.group_loan_product.principal 
      # end
      # 
      # it "should increase personal potential loss interest revenue" do
      #   @uncollectible_glm.reload 
      #   @final_potential_loss_interest_revenue = @uncollectible_glm.potential_loss_interest_revenue
      #   @initial_potential_loss_interest_revenue
      #   
      #   diff = @final_potential_loss_interest_revenue - @initial_potential_loss_interest_revenue
      #   diff.should == @uncollectible_glm.group_loan_product.interest 
      # end
      
      it 'should allow uncollectible amount' do
        final_uncollectible_weekly_payment_amount = @second_group_loan_weekly_collection.extract_uncollectible_weekly_payment_amount
        final_uncollectible_weekly_payment_amount.should == @uncollectible_glm.group_loan_product.weekly_payment_amount
      end

      it 'should NOT be deletable' do
        @first_gl_wu.delete_object
        @first_gl_wu.errors.size.should_not == 0 
        @first_gl_wu.persisted?.should be_truthy  
      end

      it 'should not allow creation of uncollectible' do
        @second_uncollectible_glm = @group_loan.active_group_loan_memberships.last 
         
        
        @second_gl_wu = GroupLoanWeeklyUncollectible.create_object({
          :group_loan_id => @group_loan.id,
          :group_loan_membership_id => @second_uncollectible_glm.id ,
          :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id ,
          :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]  
        })
        
        @second_gl_wu.should_not be_valid 
        @group_loan.reload
      end
        
        
      it 'should confirm the second_group_loan_weekly_collection' do
        @second_group_loan_weekly_collection.is_confirmed.should be_truthy 
      end
      
       
     
    
      context "closing the group loan" do
        before(:each) do
          @group_loan.group_loan_weekly_collections.order("id ASC").each do |x|
            x.collect(:collected_at => DateTime.now)
            x.confirm(:confirmed_at => DateTime.now) 
          end
          
          @group_loan.reload
        end
        

        
        it 'should not allow group loan closing if there are uncleared uncollectibles' do
          @group_loan.close(:closed_at => @closed_at)
          @group_loan.errors.size.should_not == 0 
          @group_loan.is_closed.should be_falsey 
        end
        
        
        context "collect uncollectibles" do
          before(:each) do
            @first_gl_wu.collect(:collected_at => @uncollectible_collected_at)
          end
          
          it 'should be collected' do
            @first_gl_wu.is_collected.should be_truthy 
          end
          
          context "clear uncollectibles"  do
            before(:each) do
              @group_loan.reload
              @initial_group_loan_bad_debt_allowance = @group_loan.bad_debt_allowance
              
              @first_gl_wu.clear(:cleared_at => @cleared_at)

              @first_gl_wu .reload
              @group_loan.reload
            end


            it 'should set the bad debt allowance == 0 ' do
              @group_loan.bad_debt_allowance.should == BigDecimal('0')
            end


            it 'should NOT update the group loan default amount' do
              # because it has nothing to do with group. it is personal member's allowance
              @group_loan.reload
              final_group_loan_bad_debt_allowance = @group_loan.bad_debt_allowance
              diff = final_group_loan_bad_debt_allowance - @initial_group_loan_bad_debt_allowance
              
              diff.should == BigDecimal("0") # -1*@uncollectible_glm.group_loan_product.principal 
            end



            it 'should clear the gl_wu' do
              @first_gl_wu.errors.messages.each {|x| puts "msg: #{x}"}
              @first_gl_wu .is_cleared.should be_truthy  
            end

            it 'should allow group loan closing if the uncollectibles are cleared' do
              @group_loan.reload
              @group_loan.close(:closed_at => @closed_at )

              @group_loan.is_closed.should be_truthy 
              @group_loan.errors.size.should == 0 
            end
          end
        end
        
      end
     
    end
  end
end


