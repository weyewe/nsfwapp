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
  
  
  it 'should have started the loan' do
    @group_loan.is_loan_disbursed.should be_truthy 
    @group_loan.is_started.should be_truthy 
  end
  
  context "undisburse the loan without any weekly_collection" do
    before(:each) do
      @initial_group_loan_weekly_collection_count = @group_loan.group_loan_weekly_collections.count
      @group_loan.undisburse
      @group_loan.reload 
    end
    
    it 'should not have any group_loan_weekly_collections' do
      @group_loan.group_loan_weekly_collections.count.should == 0 
    end
    
    it 'should not have any savings entries' do
      SavingsEntry.where(
        :financial_product_id => @group_loan.id ,
        :financial_product_type => @group_loan.class.to_s ,
      ).count.should == 0 
    end
    
    it 'should not have any transaction activity'  
  end
  
  context "with one collected weekly collection, no other baggages" do
    before(:each) do
      @first_glwc = @group_loan.group_loan_weekly_collections.order("id ASC").first 
      @first_glwc.collect(
        :collected_at => DateTime.now
      )
     
      @group_loan.reload
      @first_glwc.reload 
    end
    
    
    
    it 'should have one confirmed glwc' do
      @first_glwc.is_confirmed.should be_falsey
      @first_glwc.is_collected.should be_truthy   
    end
    
    it 'should not be able to undisburse' do
      @group_loan.undisburse
      # @group_loan.errors.size.should_not == 0 
      @group_loan.reload
      @group_loan.is_loan_disbursed.should be_truthy 
    end
  end
  
  context "with one open weekly collection, and other baggages included" do
    before(:each) do
      @first_glm = @group_loan.group_loan_memberships.first 
      @first_glwc = @group_loan.group_loan_weekly_collections.where(:week_number => 1 ).first 
    end
    
    context "first week has member deceased" do
      before(:each) do 
        @first_glm.member.mark_as_deceased(
          :deceased_at => DateTime.now 
        )
        @group_loan.reload 
      end
      
      it 'should not allow to unconfirm' do
        @group_loan.undisburse
        @group_loan.errors.size.should_not == 0
        @group_loan.reload  
        @group_loan.is_loan_disbursed.should be_truthy
      end
    end
    
    context "first week has member run_away" do
      before(:each) do 
        @first_glm.member.mark_as_run_away(
          :run_away_at => DateTime.now 
        )
        @group_loan.reload
      end
      
      it 'should not allow to unconfirm' do
        @group_loan.undisburse
        @group_loan.errors.size.should_not == 0
        @group_loan.reload  
        @group_loan.is_loan_disbursed.should be_truthy
      end
    end
    
    context "next week has member uncollectibles" do
      before(:each) do 
        @glwu = GroupLoanWeeklyUncollectible.create_object( 
        :group_loan_id                     => @group_loan.id , 
        :group_loan_membership_id          => @first_glm.id , 
        :group_loan_weekly_collection_id   => @first_glwc.id, 
        :clearance_case =>  UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
        )

        @group_loan.reload 
      end
      
      it 'should not allow to unconfirm' do
        @group_loan.undisburse
        @group_loan.errors.size.should_not == 0
        @group_loan.reload  
        @group_loan.is_loan_disbursed.should be_truthy
      end
    end
    
    context "next week has member premature clearance" do
      before(:each) do
        
        @glpc =  GroupLoanPrematureClearancePayment.create_object( 
          :group_loan_id                    => @group_loan.id , 
          :group_loan_membership_id         =>  @first_glm.id , 
          :group_loan_weekly_collection_id  => @first_glwc.id 
        )

        @group_loan.reload
        
      end
      
      it 'should not allow to unconfirm' do
        @group_loan.undisburse
        @group_loan.errors.size.should_not == 0
        @group_loan.reload  
        @group_loan.is_loan_disbursed.should be_truthy
      end
    end
    
    context "next week has member grouploan weekly collection voluntary savings" do
      before(:each) do
        
        @glwcvs =  @object = GroupLoanWeeklyCollectionVoluntarySavingsEntry.create_object( 
          :amount        => BigDecimal( "150000"),
          :group_loan_membership_id => @first_glm.id ,
          :group_loan_weekly_collection_id => @first_glwc.id ,
          :direction => FUND_TRANSFER_DIRECTION[:incoming]
        )

        @group_loan.reload
        
        
        
      end
      
      it 'should not allow to unconfirm'   do
        @group_loan.undisburse
        @group_loan.errors.size.should_not == 0
        @group_loan.reload  
        @group_loan.is_loan_disbursed.should be_truthy
      end
    end
  end
   

end

