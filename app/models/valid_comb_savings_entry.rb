class ValidCombSavingsEntry < ActiveRecord::Base
  belongs_to :member
  
  def self.create_object(params) 
    new_object = self.new
    new_object.member_id        = params[:member_id     ]
    new_object.month            = params[:month           ]
    new_object.year             = params[:year            ]
    new_object.savings_status   = params[:savings_status  ]
    new_object.amount           = params[:amount          ]
    new_object.save 
  end
  
  def self.starting_valid_comb_in_the_month( beginning_of_month, member, selected_savings_status )
    self.where(
      :member_id      => member.id               ,
      :month          => beginning_of_month.month               ,
      :year           =>  beginning_of_month.year               ,
      :savings_status =>  selected_savings_status 
    ).first 
  end
  
  def self.calculate_valid_comb_at_the_end_of_the_month( beginning_of_month , member,  selected_savings_status )
    starting_valid_comb = ValidCombSavingsEntry.starting_valid_comb_in_the_month( beginning_of_month, member, selected_savings_status )
    
    latest_amount = BigDecimal("0")
    
    if starting_valid_comb.nil?
      starting_amount = BigDecimal("0") 
    else
      starting_amount = starting_valid_comb.amount 
    end
      
    start_datetime = beginning_of_month 
    end_datetime = beginning_of_month + 1.month  
    
    savings_entries = SavingsEntry.where{
      ( savings_status.eq selected_savings_status ) &
      ( confirmed_at.gte start_datetime) & 
      ( confirmed_at.lt end_datetime) & 
      ( is_confirmed.eq true ) & 
      ( member_id.eq member.id )
    }
    
    positive_mutation = savings_entries.where(:direction => FUND_TRANSFER_DIRECTION[:incoming]).sum("amount")
    negative_mutation = savings_entries.where(:direction => FUND_TRANSFER_DIRECTION[:outgoing]).sum("amount")
    
    net_mutation = positive_mutation - negative_mutation 
    valid_comb_amount = starting_amount +  net_mutation 
    
    
    
    # valid comb at the end of the beginning_of_month
    self.create_object(
      :member_id      => member.id               ,
      :month          => end_datetime.month               ,
      :year           =>  end_datetime.year               ,
      :savings_status =>  selected_savings_status,
      :amount         => valid_comb_amount
    )
  end
  
  
  # we want to generate valid comb every friday. 
  
  def self.generate_valid_comb( selected_savings_status )
    first_savings_entry =  SavingsEntry.where(:is_confirmed => true, :savings_status => selected_savings_status ).order("confirmed_at ASC").first 
    beginning_of_month =  first_savings_entry.confirmed_at.beginning_of_month
    now = DateTime.now 
    
    if first_savings_entry.nil?
      
    else
      Member.find_each do |member|
        
        puts "\n\n===================> member #{member.id_number}"
        
        beginning_of_month = first_savings_entry.confirmed_at.beginning_of_month
        
       
        
        while beginning_of_month <= now do
          # will calculate the starting balance of next month 
          # or ending balance of this month  
          ValidCombSavingsEntry.calculate_valid_comb_at_the_end_of_the_month( beginning_of_month , member,  selected_savings_status)
          beginning_of_month = beginning_of_month + 1.month
        end
        
        
      end
    end
  end
end
