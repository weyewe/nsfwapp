# on confirm 
#   => update member's voluntary savings OK 
#   => Create GroupLoanWeeklyPayment OK 
#   => update member's compulsory savings  OK 
#   => confirm the premature clearance ( if there is any )

require 'spec_helper'

describe GroupLoanWeeklyCollection do
  
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
    
    
    @started_at = DateTime.new(2013,9,5,0,0,0)
    @closed_at = DateTime.new(2013,12,5,0,0,0)
    @disbursed_at = DateTime.new(2013,10,10,0,0,0)
    @withdrawn_at = DateTime.new(2013,12,6,0,0,0)
    
    @collected_at = DateTime.new( 2013, 10,10, 0 , 0 , 0)
    @confirmed_at = DateTime.new( 2013, 10, 14, 0 , 0, 0)
    
    @group_loan = GroupLoan.create_object({
      :name                             => "Group Loan 1" ,
      :number_of_meetings => 3 
    })
    
    Member.all.each do |member|
      glp_index = rand(0..1)
      selected_glp = @glp_array[glp_index]

      GroupLoanMembership.create_object({
        :group_loan_id => @group_loan.id,
        :member_id => member.id ,
        :group_loan_product_id => selected_glp.id
      })
    end
    
    @group_loan.start(:started_at => @started_at )
    @group_loan.reload 
    
    @group_loan.disburse_loan(:disbursed_at => @disbursed_at )
    @group_loan.reload 
  end
  
  it 'should have disbursed the group loan' do
    @group_loan.is_loan_disbursed.should be_truthy 
  end
  
  context "setup the group loan to perform 2 weekly collections successfully per normal" do
    before(:each) do
      x_start = 0 
      x_diff = 3 
      @group_loan.group_loan_weekly_collections.each do |glwc|
        glwc.collect(
          :collected_at => @collected_at + (x_start * x_diff).days
        )
        glwc.reload
        glwc.confirm( 
          :confirmed_at => @confirmed_at + (x_start * x_diff ).days 
        )
        
        
        
        x_start += 1
        break if x_start == 2 
        
      end
    end
    
    it 'should have total 2 group loan weekly collections confirmed' do
      @group_loan.reload
      @group_loan.group_loan_weekly_collections.where(:is_confirmed => true).count.should == 2 
    end
    
    it 'should not allow unconfirm of weekly collection 1' do
      @first_glwc = @group_loan.group_loan_weekly_collections.where(:is_confirmed => true).order("id ASC").first 
      @first_glwc.unconfirm
      
      @first_glwc.errors.size.should_not == 0 
      @first_glwc.reload
      @first_glwc.is_confirmed.should be_truthy 
    end
  end
  
  
  context "confirming 1 weekly collection with no voluntary savings => create group loan weekly payment" do
    before(:each ) do
      @first_glwc = @group_loan.group_loan_weekly_collections.first
      
      @first_glwc.collect( :collected_at => @collected_at )
      @first_glwc.reload
      @first_glwc.confirm(:confirmed_at => @confirmed_at )
      @first_glwc.reload
    end
    
    it 'should have confirmed the glwc' do
      @first_glwc.is_confirmed.should be_truthy 
    end
    
    it 'should have created group loan weekly paymetns' do
      @first_glwc.group_loan_weekly_payments.count.should == @group_loan.group_loan_memberships.count
      
      @group_loan.group_loan_memberships.each do |glm|
        glm.total_compulsory_savings.should == glm.group_loan_product.compulsory_savings
      end
    end
    
    context "unconfirm the weekly collection" do
      before(:each) do
        @first_glwc.unconfirm
      end
      
      it 'should unconfirm the glwc' do
        @first_glwc.is_confirmed.should be_falsey 
      end
    end
    
  end
  
  context "has 2 weekly collection. The 2nd is not confirmed, however, it has 'baggages'" do
    before(:each) do
      @first_glwc = @group_loan.group_loan_weekly_collections.order("id ASC")[0] 
      @second_glwc = @group_loan.group_loan_weekly_collections.order("id ASC")[1] 
      
      @first_glwc.collect(
        :collected_at => @collected_at  
      )
      @first_glwc.reload
      @first_glwc.confirm( 
        :confirmed_at => @confirmed_at  
      )
    end
    
    it 'should be allowed to unconfirm if there is nothing in the next weekly collection'  do
      @second_glwc.is_confirmed.should be_falsey 
      @first_glwc.reload 
      @first_glwc.is_confirmed.should be_truthy
      @first_glwc.unconfirm 
      @first_glwc.errors.size.should == 0 
      @first_glwc.is_confirmed.should be_falsey 
      # @first_glwc.reload
      #   @first_glwc.is_confirmed.should be_falsey 
    end
    
    context "next week has member deceased" do
      before(:each) do
        @first_glm = @group_loan.group_loan_memberships.first 
        @first_glm.member.mark_as_deceased(
          :deceased_at => DateTime.now 
        )
        @first_glwc.reload 
      end
      
      it 'should not allow to unconfirm' do
        @first_glwc.unconfirm
        @first_glwc.errors.size.should_not == 0
        @first_glwc.reload  
        @first_glwc.is_confirmed.should be_truthy
      end
    end
    
    context "next week has member run_away" do
      before(:each) do
        @first_glm = @group_loan.group_loan_memberships.first 
        @first_glm.member.mark_as_run_away(
          :run_away_at => DateTime.now 
        )
        @first_glwc.reload
      end
      
      it 'should not allow to unconfirm' do
        @first_glwc.unconfirm
        @first_glwc.errors.size.should_not == 0
        @first_glwc.reload  
        @first_glwc.is_confirmed.should be_truthy
      end
    end
    
    context "next week has member uncollectibles" do
      before(:each) do
        @first_glm = @group_loan.group_loan_memberships.first 
        @glwu = GroupLoanWeeklyUncollectible.create_object( 
        :group_loan_id                     => @group_loan.id , 
        :group_loan_membership_id          => @first_glm.id , 
        :group_loan_weekly_collection_id   => @second_glwc.id, 
        :clearance_case =>  UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
        )

        @first_glwc.reload 
      end
      
      it 'should not allow to unconfirm' do
        @first_glwc.unconfirm
        @first_glwc.errors.size.should_not == 0
        @first_glwc.reload  
        @first_glwc.is_confirmed.should be_truthy
      end
    end
    
    context "next week has member premature clearance" do
      before(:each) do
        @first_glm = @group_loan.group_loan_memberships.first 
        @glpc =  GroupLoanPrematureClearancePayment.create_object( 
          :group_loan_id                    => @group_loan.id , 
          :group_loan_membership_id         =>  @first_glm.id , 
          :group_loan_weekly_collection_id  => @second_glwc.id 
        )

        @first_glwc.reload
        
      end
      
      it 'should not allow to unconfirm' do
        @first_glwc.unconfirm
        @first_glwc.errors.size.should_not == 0
        @first_glwc.reload  
        @first_glwc.is_confirmed.should be_truthy
      end
    end
    
    context "next week has member grouploan weekly collection voluntary savings" do
      before(:each) do
        @first_glm = @group_loan.group_loan_memberships.first 
        @glwcvs =  @object = GroupLoanWeeklyCollectionVoluntarySavingsEntry.create_object( 
          :amount        => BigDecimal( "150000"),
          :group_loan_membership_id => @first_glm.id ,
          :group_loan_weekly_collection_id => @second_glwc.id ,
          :direction => FUND_TRANSFER_DIRECTION[:incoming]
        )

        @first_glwc.reload
        
        
        
      end
      
      it 'should not allow to unconfirm'   do
        @first_glwc.unconfirm
        @first_glwc.errors.size.should_not == 0
        @first_glwc.reload  
        @first_glwc.is_confirmed.should be_truthy
      end
    end
    
    
  end
  
  
  
  
  context "confirming 1 weekly collection with voluntary savings" do
    before(:each) do
      @first_glwc = @group_loan.group_loan_weekly_collections.first
      
      @initial_savings_account_array = []
      count = 1 
      @group_loan.group_loan_memberships.order("created_at DESC").each do |glm|
        voluntary_savings_amount = count *BigDecimal("1000")
        GroupLoanWeeklyCollectionVoluntarySavingsEntry.create_object(
          :amount                            =>  voluntary_savings_amount, 
          :group_loan_membership_id          => glm.id , 
          :group_loan_weekly_collection_id   => @first_glwc.id ,
          :direction => FUND_TRANSFER_DIRECTION[:incoming]
          
        )
        
        @initial_savings_account_array  << glm.member.total_savings_account
        count += 1
      end 
      
      @first_glwc.collect( :collected_at => @collected_at )
      @first_glwc.reload
      @first_glwc.confirm(:confirmed_at => @confirmed_at )
      @first_glwc.reload
    end
    
    it 'should increase the voluntary savings amount' do
      @first_glwc = @group_loan.group_loan_weekly_collections.first
     
      @group_loan.reload 
      index = 0 
      count = 1 
      
      @group_loan.group_loan_memberships.order("created_at DESC").each do |glm|
        voluntary_savings_amount = count *BigDecimal("1000")
        initial_final_savings_amount = @initial_savings_account_array[index]
        final_savings_amount = glm.member.total_savings_account
        
        diff = final_savings_amount - initial_final_savings_amount
        diff.should == voluntary_savings_amount
        
        index += 1 
        count += 1
      end
    end
    
    it 'should create grouploanweeklypayment' do
      @first_glwc.group_loan_weekly_payments.count.should == @group_loan.group_loan_memberships.count 
    end
    
    
    
    
    context "creating premature clearance in the second weekly collection" do
      before(:each) do
        @second_glwc = @group_loan.group_loan_weekly_collections.order("week_number ASC")[1]
        @premature_clearance_glm = @group_loan.group_loan_memberships.first 
        
        @second_gl_pc = GroupLoanPrematureClearancePayment.create_object({
          :group_loan_id => @group_loan.id,
          :group_loan_membership_id => @premature_clearance_glm.id ,
          :group_loan_weekly_collection_id => @second_glwc.id   
        })
      end
      
      it 'should create gl_pc' do
        @second_gl_pc.should be_valid 
      end
      
      context "confirming the second glwc" do
        before(:each) do
          @second_glwc.collect( :collected_at => @collected_at + 7.days )
          @second_glwc.reload
          @second_glwc.confirm(:confirmed_at => @confirmed_at + 7.days )
          @second_glwc.reload
          
          @second_gl_pc.reload 
          @premature_clearance_glm.reload 
        end
        
        it 'should create compulsory savings withdrawal' do
          @second_gl_pc.is_confirmed.should be_truthy 
        end
        
        it 'should deactivate the glm' do
          @premature_clearance_glm.is_active.should be_falsey 
        end
        
        it 'should NOT create compulsory savings withdrawal for the premature clearance' do
          # since it will be returned at the end of the loan. 
          @savings_entry_array = SavingsEntry.where( 
                  :savings_source_id => @second_gl_pc.id,
                              :savings_source_type => @second_gl_pc.class.to_s, 
                              :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
                              :direction => FUND_TRANSFER_DIRECTION[:outgoing],
                              :financial_product_id => @second_gl_pc.group_loan_id ,
                              :financial_product_type => @second_gl_pc.group_loan.class.to_s,
                              :member_id => @premature_clearance_glm.member.id,
                              :is_confirmed => true ) 
                              
          @savings_entry_array.count.should == 0 
        end
      end
    end
      
  
  end

end

