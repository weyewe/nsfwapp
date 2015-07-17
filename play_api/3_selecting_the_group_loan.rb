require 'httparty'
require 'json'
 
BASE_URL = "http://localhost:3000"


response = HTTParty.post( "#{BASE_URL}/api2/users/sign_in" ,
  { 
    :body => {
    	:user_login => { :email => "willy@gmail.com", :password => "willy1234" }
    }
  })

server_response =  JSON.parse(response.body )

auth_token  = server_response["auth_token"]


response = HTTParty.get( "#{BASE_URL}/api2/group_loans" ,
  :query => {
  	:auth_token => auth_token,
    :livesearch => 'tiung'
  })

server_response =  JSON.parse(response.body )


selected_group_loan = server_response["group_loans"].first
selected_group_loan_id = selected_group_loan["id"]

response = HTTParty.get( "#{BASE_URL}/api2/first_uncollected_weekly_collection/#{selected_group_loan_id}" ,
  :query => {
    :auth_token => auth_token
  })

server_response =  JSON.parse(response.body )


first_group_loan = server_response["group_loans"].first

=begin

  request seen by the server
  GET "/api2/first_uncollected_weekly_collection/1830?auth_token=4Q5CTZUUVFz1Fg9n1zqs"

   {"auth_token"=>"4Q5CTZUUVFz1Fg9n1zqs", "group_loan_id"=>"1830"}


  
  response sent by the server

 {"success"=>true, "total"=>10, "group_loan_id"=>1830, "group_loan_weekly_collection_id"=>52314, "week_number"=>3, "group_name"=>"H. Tiung (2) 465 ", "group_number"=>"465", "group_loan_weekly_collection_is_collected"=>false, "group_loan_memberships"=>[{"id"=>15211, "member_name"=>"Ade Erawati", "member_address"=>"Kp. Mangga \n", "member_id_number"=>"10612", "member_weekly_payment_amount"=>"50000.0", "weekly_collection_attendance_id"=>381173, "weekly_collection_payment_status"=>true, "weekly_collection_attendance_status"=>true, "weekly_collection_voluntary_savings_entry_direction"=>nil, "weekly_collection_voluntary_savings_entry_amount"=>nil, "weekly_collection_voluntary_savings_entry_id"=>nil}, {"id"=>15212, "member_name"=>"Mastirah", "member_address"=>"Kp. Mangga no.25\n", "member_id_number"=>"10613", "member_weekly_payment_amount"=>"60000.0", "weekly_collection_attendance_id"=>381172, "weekly_collection_payment_status"=>true, "weekly_collection_attendance_status"=>true, "weekly_collection_voluntary_savings_entry_direction"=>nil, "weekly_collection_voluntary_savings_entry_amount"=>nil, "weekly_collection_voluntary_savings_entry_id"=>nil}, {"id"=>15208, "member_name"=>"Sumarni", "member_address"=>"Kampung Mangga\n", "member_id_number"=>"5194", "member_weekly_payment_amount"=>"75000.0", "weekly_collection_attendance_id"=>381176, "weekly_collection_payment_status"=>true, "weekly_collection_attendance_status"=>true, "weekly_collection_voluntary_savings_entry_direction"=>nil, "weekly_collection_voluntary_savings_entry_amount"=>nil, "weekly_collection_voluntary_savings_entry_id"=>nil}, {"id"=>15210, "member_name"=>"Kasriyatun", "member_address"=>"Kampung Mangga\n", "member_id_number"=>"5193", "member_weekly_payment_amount"=>"90000.0", "weekly_collection_attendance_id"=>381174, "weekly_collection_payment_status"=>true, "weekly_collection_attendance_status"=>true, "weekly_collection_voluntary_savings_entry_direction"=>nil, "weekly_collection_voluntary_savings_entry_amount"=>nil, "weekly_collection_voluntary_savings_entry_id"=>nil}, {"id"=>15215, "member_name"=>"Daryumi", "member_address"=>"Kp. Mangga \n", "member_id_number"=>"10614", "member_weekly_payment_amount"=>"90000.0", "weekly_collection_attendance_id"=>381169, "weekly_collection_payment_status"=>true, "weekly_collection_attendance_status"=>true, "weekly_collection_voluntary_savings_entry_direction"=>nil, "weekly_collection_voluntary_savings_entry_amount"=>nil, "weekly_collection_voluntary_savings_entry_id"=>nil}, {"id"=>15207, "member_name"=>"Empai", "member_address"=>"Gang Syawal VI\n", "member_id_number"=>"5198", "member_weekly_payment_amount"=>"120000.0", "weekly_collection_attendance_id"=>381177, "weekly_collection_payment_status"=>true, "weekly_collection_attendance_status"=>true, "weekly_collection_voluntary_savings_entry_direction"=>nil, "weekly_collection_voluntary_savings_entry_amount"=>nil, "weekly_collection_voluntary_savings_entry_id"=>nil}, {"id"=>15206, "member_name"=>"Nurhayati", "member_address"=>"Jl.Balai Rakyat Timur\n", "member_id_number"=>"5195", "member_weekly_payment_amount"=>"120000.0", "weekly_collection_attendance_id"=>381178, "weekly_collection_payment_status"=>true, "weekly_collection_attendance_status"=>true, "weekly_collection_voluntary_savings_entry_direction"=>nil, "weekly_collection_voluntary_savings_entry_amount"=>nil, "weekly_collection_voluntary_savings_entry_id"=>nil}, {"id"=>15209, "member_name"=>"Restu Yuniarti", "member_address"=>"Kp. Mangga Jl. H. Tiung no.20\n", "member_id_number"=>"6949", "member_weekly_payment_amount"=>"120000.0", "weekly_collection_attendance_id"=>381175, "weekly_collection_payment_status"=>true, "weekly_collection_attendance_status"=>true, "weekly_collection_voluntary_savings_entry_direction"=>nil, "weekly_collection_voluntary_savings_entry_amount"=>nil, "weekly_collection_voluntary_savings_entry_id"=>nil}, {"id"=>15213, "member_name"=>"Iyun Ruminah", "member_address"=>"Jl.H Tiung\n", "member_id_number"=>"5197", "member_weekly_payment_amount"=>"150000.0", "weekly_collection_attendance_id"=>381171, "weekly_collection_payment_status"=>true, "weekly_collection_attendance_status"=>true, "weekly_collection_voluntary_savings_entry_direction"=>nil, "weekly_collection_voluntary_savings_entry_amount"=>nil, "weekly_collection_voluntary_savings_entry_id"=>nil}, {"id"=>15214, "member_name"=>"Uyun Nurhaeni", "member_address"=>"Kampung Mangga\n", "member_id_number"=>"5196", "member_weekly_payment_amount"=>"150000.0", "weekly_collection_attendance_id"=>381170, "weekly_collection_payment_status"=>true, "weekly_collection_attendance_status"=>true, "weekly_collection_voluntary_savings_entry_direction"=>nil, "weekly_collection_voluntary_savings_entry_amount"=>nil, "weekly_collection_voluntary_savings_entry_id"=>nil}]} 



=end

