json.success true 
json.total @total
json.records @objects do |object|
	json.id 						object.id
	json.name 			object.name  
	json.code 			object.code  
	
	json.account_case 			object.account_case
	
	if object.account_case == ACCOUNT_CASE[:ledger]
		json.account_case_text 			"Ledger"
	else
		json.account_case_text 			"Group"
	end
	
	
	
end
