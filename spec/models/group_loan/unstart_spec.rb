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
   
  it "can't be canceled if there is disbursement" do
    @group_loan.cancel_start
    @group_loan.errors.size.should_not ==0 
    @group_loan.reload 
    @group_loan.is_started.should be_truthy
  end
  
  context "undisburse group loan" do
    before(:each) do
      @group_loan.undisburse
      @group_loan.reload
    end
    
    it 'should be undisbursed' do
      @group_loan.is_loan_disbursed.should be_falsey 
    end
    
    it 'should be allowed to cancel start' do
      @group_loan.cancel_start
      @group_loan.reload
      @group_loan.is_started.should be_falsey 
    end
  end

end

