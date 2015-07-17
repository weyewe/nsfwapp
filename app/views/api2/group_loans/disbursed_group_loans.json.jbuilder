json.success true 
json.total @total 
json.group_loans @objects do |object|
 

    
	json.group_number 			object.group_number
	json.name 			 			object.name 
	json.disbursed_at 			 	object.disbursed_at 
	json.disbursement_amount		object.disbursed_fund 

end

  

