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


=begin
	
	request seen by the server:
	{"user_login"=>{"email"=>"willy@gmail.com", "password"=>"[FILTERED]"}}
	
	body from response sent from the server:
	{"success"=>true, "auth_token"=>"4Q5CTZUUVFz1Fg9n1zqs", 
				"email"=>"willy@gmail.com", 
				"role"=>"{\"system\":{\"administrator\":true}}"} 


	In the faulty situation ( if the password/email is wrong):
	{"success"=>false, "message"=>"Error with your login or password"} 
	
=end