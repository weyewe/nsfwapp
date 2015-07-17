=begin
  
result = [] 
Member.find_each do |x|
  result << x.name  if x.group_loan_memberships.count > 1 
  
  break if result.length == 50 

end
=end



role = {
  :system => {
    :administrator => true
  }
}

admin_role = Role.create!(
  :name        => ROLE_NAME[:admin],
  :title       => 'Administrator',
  :description => 'Role for administrator',
  :the_role    => role.to_json
)

role = {
  :passwords => {
    :update => true 
  },
  :members => {
    :index => true,
    :search => true 
  },
  :group_loan_products => {
    :index => true ,
    :search => true 
  },
  :group_loans => {
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true,
  },
  :group_loan_memberships => {
    :search => true ,
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true,
    :deactivate => true 
  },
  :group_loan_weekly_collections => {
    :search => true ,
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true,
    :collect => true,
    :uncollect => true 
  },
  
  :group_loan_weekly_uncollectibles => {
    :search => true ,
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true,
    :clear => true,
    :collect => true,
  },
  :group_loan_premature_clearance_payments => {
    :search => true ,
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true 
  },
  
  :savings_entries => {
    :search => true ,
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true 
  }
}
=begin

old_role = Role.find_by_name("dataentry")
new_role_hash = {
  :passwords => {
    :update => true 
  },
  :members => {
    :index => true,
    :search => true 
  },
  :group_loan_products => {
    :index => true ,
    :search => true 
  },
  :group_loans => {
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true,
  },
  :group_loan_memberships => {
    :search => true ,
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true,
    :deactivate => true 
  },
  :group_loan_weekly_collections => {
    :search => true ,
    :index => true, 
    :active_group_loan_memberships => true, 
    :create => true,
    :update => true,
    :destroy => true,
    :collect => true ,
    :uncollect => true, 
    :show => true ,
    
  },
  
  :group_loan_weekly_uncollectibles => {
    :search => true ,
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true,
    :collect => true, 
    :uncollect => true 
  },
  :group_loan_premature_clearance_payments => {
    :search => true ,
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true 
  },
  
  :savings_entries => {
    :search => true ,
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true,
    :show => true 
  },
  :group_loan_weekly_collection_voluntary_savings_entries => {
    :search => true ,
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true
  }
}
old_role.update_role(new_role_hash)
=end

data_entry_role = Role.create!(
  :name        => ROLE_NAME[:data_entry],
  :title       => 'Data Entry',
  :description => 'Role for data_entry',
  :the_role    => role.to_json
)



# if Rails.env.development?

=begin
  CREATING THE USER 
  
  admin = User.create_main_user(  :name => "Admin2", :email => "admin2@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
  admin.set_as_main_user
  
  admin = User.create_main_user(  :name => "Admin4", :email => "admin4@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
  admin.set_as_main_user
=end

  admin = User.create_main_user(  :name => "Admin", :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
  admin.set_as_main_user
  
  admin = User.create_main_user(  :name => "Leon", :email => "leonardo.kamilius@gmail.com" ,:password => "leon1234", :password_confirmation => "leon1234") 
  admin.set_as_main_user
  
  admin = User.create_main_user(  :name => "Admin", :email => "admin3@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
  admin.set_as_main_user
  
  admin = User.create_main_user(  :name => "Admin", :email => "admin4@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
  admin.set_as_main_user


  data_entry1 = User.create_object(:name => "Data Entry", :email => "data_entry1@gmail.com", 
                :password => 'willy1234', 
                :password_confirmation => 'willy1234',
                :role_id => data_entry_role.id )
              
  data_entry1.password = 'willy1234'
  data_entry1.password_confirmation = 'willy1234'
  data_entry1.save

  data_entry2 = User.create_object(:name => "Data Entry", :email => "data_entry2@gmail.com", 
                :password => 'willy1234', 
                :password_confirmation => 'willy1234',
                :role_id => data_entry_role.id )
              
  data_entry2.password = 'willy1234'
  data_entry2.password_confirmation = 'willy1234'
  data_entry2.save
  
  
  # ["data_entry1@gmail.com", "data_entry2@gmail.com", "admin2@gmail.com", "admin@gmail.com", "admin4@gmail.com", "admin3@gmail.com"]
  


  user_array = [admin, data_entry1, data_entry2]


# 
=begin
  CREATING THE Member 
=end
  member_array = []
  (1..80).each do |number|
    member = Member.create_object({
      :name =>  "Member #{number}",
      :address => "Address alamat #{number}" ,
      :id_number => "342432#{number}"
    })
    member_array << member 
  end

 
  # customer_array = [cust_1, cust_2, cust_3, cust_4] 
  
  member_array = Member.all 

# =begin
#   Create GroupLoanProduct
# =end
# 
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
  
  glp_array = [
    @group_loan_product_1,
    @group_loan_product_2
    ]

=begin
  Create seed group_loan 
=end

  @group_loan_1 = GroupLoan.create_object({
    :name                             => "Group Loan 1 (no bad expense)" ,
    :number_of_meetings => 3 
  })
  
  @group_loan_2 = GroupLoan.create_object({
    :name                             => "Group Loan 2" ,
    :number_of_meetings => 5
  })
  
  @group_loan_3 = GroupLoan.create_object({
    :name                             => "Group Loan 3: with bad expense" ,
    :number_of_meetings => 3 
  })
  
   
  
  
=begin
  Create seed glm
=end
  # # Member.order("ASC")limit(10).
  member_array[0..9].each do |member|
    selected_index=  rand(0..1)
    selected_glp = glp_array[selected_index]
    GroupLoanMembership.create_object({
      :group_loan_id => @group_loan_1.id,
      :member_id => member.id ,
      :group_loan_product_id => selected_glp.id
    })
  end
  
  # create group loan 3 
  member_array[10..19].each do |member|
    selected_index=  rand(0..1)
    selected_glp = glp_array[selected_index]
    GroupLoanMembership.create_object({
      :group_loan_id => @group_loan_3.id,
      :member_id => member.id ,
      :group_loan_product_id => selected_glp.id
    })
  end
  
  
=begin
  Start the group loan  1
=end
  @group_loan_1.start(:started_at => DateTime.now )
  
  @group_loan_1.disburse_loan(:disbursed_at => DateTime.now )
  
  @deceased_glm = @group_loan_1.group_loan_memberships.first 
  @deceased_member = @deceased_glm.member 
  
  
  
  @run_away_glm = @group_loan_1.group_loan_memberships[2]
  @run_away_member = @run_away_glm.member
  
  @premature_clearance_glm = @group_loan_1.group_loan_memberships[5]
  @premature_clearance_member = @premature_clearance_glm.member 
  
  
  
  @savings_member = Member.last
  
  
  (1..10).each do |x|
    
    
    se = SavingsEntry.create_object(
      :amount => BigDecimal( (x*10000).to_s ),
      :direction => FUND_TRANSFER_DIRECTION[:incoming],
      :member_id => @savings_member.id 
     )
    se.confirm(:confirmed_at => DateTime.now )
  end
  
  
=begin
  Finish weekly collection on group_loan_1 
=end
  
  @group_loan_1.group_loan_weekly_collections.order("id ASC").each do |x|
    break if x.week_number == 2
    x.collect(:collected_at => DateTime.now)
    x.confirm(:confirmed_at => DateTime.now)
  end
  
  # create deceased 
  @deceased_member.mark_as_deceased(:deceased_at => DateTime.now )
  
  
  @group_loan_1.group_loan_weekly_collections.order("id ASC").each do |x|
    next if x.is_collected?   and x.is_collected?
    break if x.week_number == 4
    x.collect(:collected_at => DateTime.now)
    x.confirm(:confirmed_at => DateTime.now)
  end
  
  # create run_away 
  @fourth_week_collection = @group_loan_1.group_loan_weekly_collections.where(:week_number => 4 ).first 
  @run_away_member.mark_as_run_away( :run_away_at => DateTime.now )
  
  @group_loan_1.group_loan_weekly_collections.order("id ASC").each do |x|
    next if x.is_collected?   and x.is_collected?
    break if x.week_number == 6 
    x.collect(:collected_at => DateTime.now)
    x.confirm(:confirmed_at => DateTime.now)
  end
  
  
  # create premature clearance
  @sixth_week_collection = @group_loan_1.group_loan_weekly_collections.where(:week_number => 6 ).first 
  
  @premature_clearance = GroupLoanPrematureClearancePayment.create_object(
    :group_loan_id                    => @group_loan_1.id , 
    :group_loan_membership_id         => @premature_clearance_glm.id , 
    :group_loan_weekly_collection_id  => @sixth_week_collection.id 
  )
  
  @group_loan_1.group_loan_weekly_collections.order("id ASC").each do |x|
    next if x.is_collected?   and x.is_collected?
    
    x.collect(:collected_at => DateTime.now)
    x.confirm(:confirmed_at => DateTime.now)
  end
  
  
=begin
  ################## FOR Group Loan 3 
=end
  @group_loan_3.start(:started_at => DateTime.now )
  
  @group_loan_3.disburse_loan(:disbursed_at => DateTime.now )
  
  @deceased_glm = @group_loan_3.group_loan_memberships.first 
  @deceased_member = @deceased_glm.member 
  
  
  
  @run_away_glm = @group_loan_3.group_loan_memberships[2]
  @run_away_member = @run_away_glm.member
  
  @premature_clearance_glm = @group_loan_3.group_loan_memberships[5]
  @premature_clearance_member = @premature_clearance_glm.member 

    
   
   @group_loan_3.group_loan_weekly_collections.order("id ASC").each do |x|
     break if x.week_number == 2
     x.collect(:collected_at => DateTime.now)
     x.confirm(:confirmed_at => DateTime.now)
   end
   
   # create deceased 
   @deceased_member.mark_as_deceased(:deceased_at => DateTime.now )
   
   
   @group_loan_3.group_loan_weekly_collections.order("id ASC").each do |x|
     next if x.is_collected?   and x.is_collected?
     break if x.week_number == 4
     x.collect(:collected_at => DateTime.now)
     x.confirm(:confirmed_at => DateTime.now)
   end
   
   # create run_away 
   @fourth_week_collection = @group_loan_3.group_loan_weekly_collections.where(:week_number => 4 ).first 
   @run_away_member.mark_as_run_away( :run_away_at => DateTime.now )
   
   @group_loan_3.group_loan_run_away_receivables.each do |x|
     x.set_payment_case(:payment_case =>  GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle])
   end
   
   @group_loan_3.group_loan_weekly_collections.order("id ASC").each do |x|
     next if x.is_collected?   and x.is_collected?
     break if x.week_number == 6 
     x.collect(:collected_at => DateTime.now)
     x.confirm(:confirmed_at => DateTime.now)
   end
   # 
   # 
   # 
   # 
   # # # create premature clearance
   # @sixth_week_collection = @group_loan_3.group_loan_weekly_collections.where(:week_number => 6 ).first 
   # 
   # @premature_clearance = GroupLoanPrematureClearancePayment.create_object(
   #   :group_loan_id                    => @group_loan_3.id , 
   #   :group_loan_membership_id         => @premature_clearance_glm.id , 
   #   :group_loan_weekly_collection_id  => @sixth_week_collection.id 
   # )
   # 
   # @group_loan_3.group_loan_weekly_collections.order("id ASC").each do |x|
   #   next if x.is_collected?   and x.is_collected?
   #   
   #   x.collect(:collected_at => DateTime.now)
   #   x.confirm(:confirmed_at => DateTime.now)
   # end
   # 
  
  
  # 
  

  def make_date(*args)
    now = DateTime.now  
  
    d = ( args[0] || 0 )
    h = (args[1]  || 0)  
    m = (args[2] || 0)  
    s = (args[3] || 0)  
  
  
    target_date = ( now  + d.days + h.hours + m.minutes + s.seconds   ) .new_offset( Rational(0,24) ) 
  
    adjusted_date = DateTime.new( target_date.year, target_date.month, target_date.day, 
                                  h, 0 , 0 
              ) .new_offset( Rational(0,24) ) 
  
    # return ( now  + d.days + h.hours + m.minutes + s.seconds   ) .new_offset( Rational(0,24) ) 
    return adjusted_date 
  end

  def make_date_mins(*args)
    now = DateTime.now  
  
    d = ( args[0] || 0 )
    h = (args[1]  || 0)  
    m = (args[2] || 0)  
    s = (args[3] || 0)  
  
  
    target_date = ( now  + d.days + h.hours + m.minutes + s.seconds   ) .new_offset( Rational(0,24) ) 
  
  
    # what is being adjusted 
    adjusted_date = DateTime.new( target_date.year, target_date.month, target_date.day, 
                                  target_date.hour, target_date.minute , target_date.second
              ) .new_offset( Rational(0,24) ) 
  
    return adjusted_date
  end
    
 
# end

=begin

admin = User.create_main_user(  :name => "Willy", :email => "willy@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
admin.set_as_main_user


array = [
"data_entry1@gmail.com", 
"data_entry2@gmail.com"
]

array.each do |x|
  user = User.find_by_email x 
  
  user.recover_object 
end
=end

=begin
  Data entry role 
  
  
  data_entry_role = {
    :passwords => {
      :update => true 
    },
    :calendars => {
      :search => true,
      :index => true ,
      # there are 2: update is hack for extensible.. 
      # update details  => authorization to update discount, calendar name, etc
      :update => true,
      :update_details => false 
    },
    :customers => {
      :new => true,
      :create => true, 
      :edit => true, 
      :update => true ,
      :destroy => true  ,
      :index => true ,
      :search => true 
    },
    :bookings => {
      :new => true,
      :create => true, 
      :edit => true, 
      :update => true ,
      :destroy => true ,
      :confirm => true,
      :pay => true, 
      :index => true ,
      :search => true,
      :update_start_datetime => true, 
      :update_end_datetime => true 
    } ,
    :events => {
      :index => true 
    }
  }

  data_entry_role = Role.create!(
    :name        => ROLE_NAME[:data_entry],
    :title       => 'Data Entry',
    :description => 'Role for data entry',
    :the_role    => data_entry_role.to_json
  )


=end

# (1.upto 5).each do |x|
# Branch.create_object({
#   :name => "Branch #{x}",
#   :address => "Address #{x}",
#   :code => "code #{x}",
#   :description => "description #{x}"

#   })
# end