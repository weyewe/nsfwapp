
json.success true 
json.total @total
json.group_loan_products @objects do |object|
	json.id 								object.id  
	json.name 							object.name
	json.total_weeks 				object.total_weeks
	json.principal 					object.principal
	json.interest 					object.interest 
	json.compulsory_savings object.compulsory_savings 
	json.admin_fee 					object.admin_fee
	json.weekly_payment_amount		 object.weekly_payment_amount 
	
	json.initial_savings		 object.initial_savings 

end




