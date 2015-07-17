require 'spec_helper'

describe GroupLoan do
  
  before(:each) do
    # # Account.create_base_objects
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
      
      it 'should have equal total count of glm and member' do
        @group_loan.group_loan_memberships.count.should == Member.count
      end
      
      context "starting the group_loan" do
        before(:each) do
          @group_loan.start(:started_at => @started_at) 
          @group_loan.reload 
        end
        
        it 'should have started group loan' do
          @group_loan.is_started.should be_truthy 
        end
        
        it 'should manifest the number of collections' do
          @group_loan.number_of_collections.should == @group_loan.loan_duration 
        end
        
        context "execute loan disbursement" do
          before(:each) do
            @group_loan.disburse_loan(:disbursed_at => @disbursed_at)
          end
          
          it 'should be marked as loan disbursed' do
            @group_loan.is_loan_disbursed.should be_truthy 
          end
          
          it 'should have created N GroupLoanDisbursement' do
            @group_loan.group_loan_disbursements.count.should == GroupLoanDisbursement.all.count 
          end
          
          it 'should have created N GroupLoanWeeklyCollection' do
            @group_loan.group_loan_weekly_collections.count.should == @group_loan.number_of_collections
          end
          
          it 'should be allowed to mark GroupLoanWeeklyCollection as collected' do
            @first_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC").first
            @first_group_loan_weekly_collection.should be_valid 
            @first_group_loan_weekly_collection.collect(
              {
                :collected_at => DateTime.now 
              }
            )
            
            object = DateTime.now 
            object.is_a?(DateTime).should be_truthy 
            @first_group_loan_weekly_collection.errors.messages.each {|x| puts "msg : #{x}"}
            @first_group_loan_weekly_collection.is_collected.should be_truthy 
          end
          
          it 'should not be allowed to skip week in the GroupLoanWeeklyCollection' do 
            @second_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[1]
            @second_group_loan_weekly_collection.should be_valid 
            @second_group_loan_weekly_collection.collect(
              {
                :collected_at => DateTime.now 
              }
            )
            
            @second_group_loan_weekly_collection.is_collected.should be_falsey
            @second_group_loan_weekly_collection.errors.size.should_not == 0
          end
          
          
          context "weekly payment collection: 1 week" do
            before(:each) do
              @first_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC").first
              @first_group_loan_weekly_collection.should be_valid 
              @first_glm = @group_loan.group_loan_memberships.first 
              
              @glwc_vs =   GroupLoanWeeklyCollectionVoluntarySavingsEntry.create_object( 
                :amount        => BigDecimal( "150000"),
                :group_loan_membership_id => @first_glm.id ,
                :group_loan_weekly_collection_id => @first_group_loan_weekly_collection.id ,
                :direction => FUND_TRANSFER_DIRECTION[:incoming]
              )
              
              
              @first_group_loan_weekly_collection.collect(
                {
                  :collected_at => DateTime.now 
                }
              )

              @first_group_loan_weekly_collection.is_collected.should be_truthy
              
              @first_glm = @group_loan.active_group_loan_memberships.first 
              @initial_compulsory_savings = @first_glm.total_compulsory_savings
              @first_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now)
              @first_glm.reload 
               
            end
            
            it "should confirm group loan weekly collection" do
              @first_group_loan_weekly_collection.is_collected.should be_truthy
              @first_group_loan_weekly_collection.is_confirmed.should be_truthy
            end
            
            
            
            it "should create transaction data for weekly collection" do
              TransactionData.where(:transaction_source_id => @first_group_loan_weekly_collection.id, 
                :transaction_source_type => @first_group_loan_weekly_collection.class.to_s,
                :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection]
              ).count.should == 1 

              a = TransactionData.where(:transaction_source_id => @first_group_loan_weekly_collection.id, 
                :transaction_source_type => @first_group_loan_weekly_collection.class.to_s,
                :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection]
              ).first

              a.total_debit.should == a.total_credit
              a.is_confirmed.should be_truthy 
            end
            
            it "should create transaction data for voluntary savings" do
              TransactionData.where(:transaction_source_id => @glwc_vs.id, 
                :transaction_source_type => @glwc_vs.class.to_s,
                :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection_voluntary_savings]
              ).count.should == 1 

              a = TransactionData.where(:transaction_source_id => @glwc_vs.id, 
                :transaction_source_type => @glwc_vs.class.to_s,
                :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection_voluntary_savings]
              ).first

              a.is_confirmed.should be_truthy 
              a.total_debit.should == a.total_credit
            end
            
            context "unconfirm weekly collection" do
              before(:each) do
                @first_group_loan_weekly_collection.unconfirm
              end
              
              it "should create transaction data to unconfirm weekly collection" do
                contra = TransactionData.where(:transaction_source_id => @first_group_loan_weekly_collection.id, 
                  :transaction_source_type => @first_group_loan_weekly_collection.class.to_s,
                  :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection],
                  :is_contra_transaction => true 
                ).order("id DESC").first
                
                contra.is_confirmed.should be_truthy
              end
              
              it "should create transaction data to unconfirm weekly_collection voluntary savings" do
                contra = TransactionData.where(:transaction_source_id => @glwc_vs.id, 
                  :transaction_source_type => @glwc_vs.class.to_s,
                  :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection_voluntary_savings],
                  :is_contra_transaction => true 
                ).order("id DESC").first
                
                contra.is_confirmed.should be_truthy
              end
              
            end
            
            
          end
          
       
        end
        
        
      end
      
      
    end
    
  end
end
