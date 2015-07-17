json.success true 
json.total @total
 

json.savings_entries @objects do |object|
	json.id 								object.id 
	json.member_id 			 object.member.id   
	json.member_name 			 object.member.name
	json.member_id_number 			 object.member.id_number
	
	json.direction 							object.direction
	
	if object.direction == FUND_TRANSFER_DIRECTION[:incoming] 
		json.direction_text				"Penambahan" 
	elsif object.direction == FUND_TRANSFER_DIRECTION[:outgoing]
		json.direction_text				"Penarikan" 
	end
	
	json.amount object.amount
	json.is_confirmed object.is_confirmed
	json.confirmed_at format_date_friendly( object.confirmed_at )
	 
	json.savings_status object.savings_status 
	
	if object.savings_status == SAVINGS_STATUS[:savings_account]
		json.savings_status_text				"Voluntary" 
	elsif object.savings_status == SAVINGS_STATUS[:membership]
		json.savings_status_text				"Membership" 
	elsif object.savings_status == SAVINGS_STATUS[:locked]
		json.savings_status_text				"Locked" 
	end
	
end
