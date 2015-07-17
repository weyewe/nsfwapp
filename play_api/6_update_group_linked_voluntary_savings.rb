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

selected_group_loan_weekly_collection_id = server_response["group_loan_weekly_collection_id"]
selected_glm = server_response["group_loan_memberships"].first
selected_glm_id = selected_glm["id"]
selected_voluntary_savings_id = selected_glm["weekly_collection_voluntary_savings_entry_id"]



if selected_voluntary_savings_id.nil? 
  response = HTTParty.post( "#{BASE_URL}/api2/group_loan_weekly_collection_voluntary_savings_entries" ,
    :query => {
      :auth_token => auth_token
    },
    :body => {
      :group_loan_weekly_collection_voluntary_savings_entry => {  
      :amount        =>  BigDecimal( '500000' ),
      :group_loan_membership_id =>  selected_glm_id, 
      :group_loan_weekly_collection_id =>  selected_group_loan_weekly_collection_id, 
      :direction =>   1 # 1 for addition, 2 for withdrawal
      }
    }

  )

  server_response =  JSON.parse(response.body )

  selected_voluntary_savings_id = server_response["group_loan_weekly_collection_voluntary_savings_entries"].first["id"]
end



response = HTTParty.put( "#{BASE_URL}/api2/group_loan_weekly_collection_voluntary_savings_entries/#{selected_voluntary_savings_id}" ,
  :query => {
    :auth_token => auth_token
  },
  :body => {
    :group_loan_weekly_collection_voluntary_savings_entry => {  
    :amount        =>  BigDecimal( '10000' ),
    :group_loan_membership_id =>  selected_glm_id, 
    :group_loan_weekly_collection_id =>  selected_group_loan_weekly_collection_id, 
    :direction =>   1 # 1 for addition, 2 for withdrawal
    }
  }

)

server_response =  JSON.parse(response.body )



=begin

  request seen by the server
  PUT "/api2/group_loan_weekly_collection_voluntary_savings_entries/79892?auth_token=4Q5CTZUUVFz1Fg9n1zqs"

  {"group_loan_weekly_collection_voluntary_savings_entry"=>{"amount"=>"10000.0", "group_loan_membership_id"=>"15211", "group_loan_weekly_collection_id"=>"52314", "direction"=>"1"}, "auth_token"=>"4Q5CTZUUVFz1Fg9n1zqs", "id"=>"79892"}

  response sent by the server IF SUCCESS

 {"success"=>true, "group_loan_weekly_collection_voluntary_savings_entries"=>[{"id"=>79892, "group_loan_weekly_collection_id"=>52314, "group_loan_membership_id"=>15211, "amount"=>"10000.0", "member_name"=>"Ade Erawati", "member_id_number"=>"10612"}], "total"=>1} 
  
  response sent by the server if fail
  {"success"=>false, "message"=>{"errors"=>{"generic_errors"=>"Sudah ada tabungan oleh member tersebut"}}} 


=end

