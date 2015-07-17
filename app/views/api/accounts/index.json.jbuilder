json.success true 
json.total @total
json.accounts @objects do |object|
	json.id 								object.id 
	
	if @parent
		json.parent_id					@parent.id  
		json.parent_name 				@parent.name 	
	else
		json.parent_id					 ""  
		json.parent_name 				""
	end
	
	
	
	json.name 	object.name
	json.code		object.code 
	
	if object.account_case == ACCOUNT_CASE[:ledger] 
		json.leaf true 
		json.account_case ACCOUNT_CASE[:ledger]
		json.account_case_text "Ledger"
	else
		json.leaf false 
		json.account_case ACCOUNT_CASE[:group]
		json.account_case_text "Group"
	end
	 
	if object.normal_balance  ==  NORMAL_BALANCE[:debit]
		json.normal_balance_text  "Debit"
		json.normal_balance  NORMAL_BALANCE[:debit]
	else
		json.normal_balance_text  "Credit"
		json.normal_balance  NORMAL_BALANCE[:credit]
	end
	
	json.is_contra_account object.is_contra_account 
	


	
	
end
