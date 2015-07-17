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


selected_glm = server_response["group_loan_memberships"].first
selected_glm_id = selected_glm["id"]


response = HTTParty.put( "#{BASE_URL}/api2/group_loan_weekly_collection_attendances/#{selected_glm_id}" ,
  :query => {
    :auth_token => auth_token
  },
  :body => {
    :group_loan_weekly_collection_attendance => {  
      :attendance_status =>  true , 
      :payment_status =>  false 
    }
  }

)

server_response =  JSON.parse(response.body )


=begin

  request seen by the server
  PUT "/api2/group_loan_weekly_collection_attendances/15211?auth_token=4Q5CTZUUVFz1Fg9n1zqs"

   {"group_loan_weekly_collection_attendance"=>{"attendance_status"=>"true", "payment_status"=>"false"}, "auth_token"=>"4Q5CTZUUVFz1Fg9n1zqs", "id"=>"15211"}

  
  response sent by the server

{"success"=>true, "group_loan_weekly_collection_attendances"=>[{"id"=>15211, "group_loan_weekly_collection_id"=>9404, "group_loan_membership_id"=>30, "member_name"=>"Maslahatul Hidayah", "attendance_status"=>true, "payment_status"=>false}], "total"=>7} 


=end

