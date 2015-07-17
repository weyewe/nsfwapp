=begin
Cash_Direction          Savings_Direction       What does it mean? 
 incoming                 incoming                No Such Case   (NA)
 outgoing                 outgoing                Savings Withdrawal, cash going out, savings is deducted 
 incoming                 outgoing                Payment using combination of cash and savings withdrawal
 outgoing                 incoming                No such case 


New definition: TransactionActivity is used to record cash transaction affecting the member's account

CashDirection     What does it mean?
  incoming          $$ from the member, going to the company. Example: paying admin  fee, paying the weekly collection
  outgoing          company gives $$ to the member. 
  
  
Compulsory savings deduction, how can we record it? 
It affects the member's account receivable (company's account payable). However, there is no cash movement 
between company and member.   

outgoing to the member,
incoming to the company 
=end

# transaction activity is sequential. can't record both of savings and cash movement at the same time. 

class TransactionActivity < ActiveRecord::Base
  attr_accessible :transaction_source_id, 
                  :transaction_source_type,
                  :cash,
                  :cash_direction,
                  :savings_direction, 
                  :savings, 
                  :member_id, 
                  :office_id,
                  :amount, :direction, :fund_case
                  
                  
  belongs_to :transaction_source, :polymorphic => true 
end

