


json.success true 
json.total @total
 

json.memorial_details @objects do |object| 

	json.id 								object.id 
	json.memorial_id 		  object.memorial_id  
	json.account_id 			 object.account_id
	json.account_name 			 "[#{object.account.code}] #{object.account.name}" 
	
	json.entry_case 					 object.entry_case 
	
	
	if object.entry_case == NORMAL_BALANCE[:debit]
		json.entry_case_text 					 "Debit"
	else object.entry_case == NORMAL_BALANCE[:credit]
		json.entry_case_text 					 "Kredit"
	end
	
	json.amount 						object.amount 
	json.description   object.description 
	
	
end
