require 'spec_helper'

describe GroupLoan do
  
  before(:each) do
    # Account.create_base_objects
    # create users 
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
    
    @started_at = DateTime.new(2013,10,5,0,0,0)
    @disbursed_at = DateTime.new(2013,10,10,0,0,0)
    @closed_at = DateTime.new(2013,12,5,0,0,0)
    @withdrawn_at = DateTime.new(2013,12,6,0,0,0)
  end
  
  
=begin
  Create Member 
  Create GroupLoanProduct
  Create GroupLoanMembership 
  
  Start Loan => Cashier has to prepare the $$ to be disbursed, and mark it as Cash prepared. 
    Receipt of cash passed from cashier to loan officer is done offline. 
    
    # DISBURSEMENT process is done offline. 
    # computer only wants to know the amount of $$ disbursed. 
  Trigger loan disbursement 
    Loan Officer come back with the contract + The list of members whose loan is disbursed + the excess 
      cash undisbursed. The excess cash must be equal to the sum of money allocated to the member
      not present @loan disbursement. This excess money will go to the moneyshelf. => Done. 
      
      Later, when they are about to bank the excess, use normal accounting procedure to move from
      moneyshelf to bank account 
      
  Weekly Payment Collection
    
  Close the group loan 
=end
  context "normal operation: no corner cases, no update, uber-ideal case" do
    before(:each) do
      
      @group_loan = GroupLoan.create_object({
        :name                             => "Group Loan 1" ,
        :number_of_meetings => 3 
      })
      
    end
    
    it 'should produce group_loan' do
      @group_loan.should be_valid 
    end
    
    context "create group loan membership" do
      
      before(:each) do 
        Member.all.each do |member|
          glp_index = rand(0..1)
          selected_glp = @glp_array[glp_index]

          GroupLoanMembership.create_object({
            :group_loan_id => @group_loan.id,
            :member_id => member.id ,
            :group_loan_product_id => selected_glp.id
          })
        end
      end
       
      
      context "starting the group_loan" do
        before(:each) do
          @group_loan.start(:started_at => @started_at) 
          @group_loan.reload 
        end
        
    
        
        context "execute loan disbursement" do
          before(:each) do
            @group_loan.disburse_loan(:disbursed_at => @disbursed_at)
          end
          
       
          
          it "should create transaction data" do
            TransactionData.where(:transaction_source_id => @group_loan.id, 
              :transaction_source_type => @group_loan.class.to_s,
              :code => TRANSACTION_DATA_CODE[:loan_disbursement]
            ).count.should == 1 
            
            a = TransactionData.where(:transaction_source_id => @group_loan.id, 
              :transaction_source_type => @group_loan.class.to_s,
              :code => TRANSACTION_DATA_CODE[:loan_disbursement]
            ).first
            
            a.total_debit.should == a.total_credit 
          end
          
          context "undo loan disbursement" do
            before(:each) do
              @group_loan.undisburse
            end
            
            it "should undisburse" do
              @group_loan.is_loan_disbursed.should be_falsey 
            end
            
            it "should create 2 transaction_data" do
              TransactionData.where(:transaction_source_id => @group_loan.id, 
                :transaction_source_type => @group_loan.class.to_s,
                :code => TRANSACTION_DATA_CODE[:loan_disbursement]
              ).count.should == 2

              contra = TransactionData.where(:transaction_source_id => @group_loan.id, 
                :transaction_source_type => @group_loan.class.to_s,
                :code => TRANSACTION_DATA_CODE[:loan_disbursement],
                :is_contra_transaction => true 
              ).order("id DESC").first
              
              contra.is_contra_transaction.should be_truthy 
              contra.is_confirmed.should be_truthy
            end
            
            context " re-doing loan disbursement" do
              before(:each) do
                @group_loan.disburse_loan(:disbursed_at => @disbursed_at)
              end
              
              it "should create 3 transaction_data" do
                TransactionData.where(:transaction_source_id => @group_loan.id, 
                  :transaction_source_type => @group_loan.class.to_s,
                  :code => TRANSACTION_DATA_CODE[:loan_disbursement]
                ).count.should == 3
              end
            end
          end
          
       
        end
        
        
      end
      
      
    end
    
  end
end
