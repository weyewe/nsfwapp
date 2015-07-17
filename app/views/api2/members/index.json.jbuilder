
json.success true 
json.total @total
json.members @objects do |object|
	json.id 								object.id  
 
	
	json.name object.name
	json.address object.address
	json.id_number object.id_number
	
	json.is_run_away object.is_run_away
	json.is_deceased object.is_deceased
	
	
	
	
	
	json.total_savings_account object.total_savings_account
	json.total_locked_savings_account object.total_locked_savings_account
	json.total_membership_savings object.total_membership_savings
	
	
	json.id_card_number object.id_card_number
	json.birthday_date 	format_date_friendly( object.birthday_date )
	json.is_data_complete object.is_data_complete
	
	json.rt object.rt
	json.rw object.rw
	json.village object.village
	
	if not object.group_loan_memberships.where(:is_active =>true ).first.nil?
		json.active_group_loan_name  object.group_loan_memberships.where(:is_active => true).first.group_loan.id_number_name 
	else
		json.active_group_loan_name  "NA" 
	end
	
end




 