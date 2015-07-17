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


=begin

  request seen by the server
  "/api2/group_loans?auth_token=4Q5CTZUUVFz1Fg9n1zqs&livesearch=tiung"

   {"auth_token"=>"4Q5CTZUUVFz1Fg9n1zqs", "livesearch"=>"tiung"}

  
  response sent by the server

  {"success"=>true, "total"=>4, 
  "group_loans"=>[
              {"id"=>1830, "name"=>"H. Tiung (2) 465 ", "group_number"=>"465"}, 
              {"id"=>1829, "name"=>"H. Tiung (2) 466", "group_number"=>"466"}, 
              {"id"=>1218, "name"=>"H. Tiung 594", "group_number"=>"594"}, 
              {"id"=>989, "name"=>"H. Tiung 281", "group_number"=>"281"}]} 


=end

