json.success true 
json.total @total
json.group_loan_weekly_collection_voluntary_savings_entries @objects do |object|
	json.id 								object.id 
	
	json.group_loan_weekly_collection_id object.group_loan_weekly_collection_id
	json.group_loan_membership_id object.group_loan_membership_id 
	
	json.amount object.amount
	
	json.member_name object.group_loan_membership.member.name
	json.member_id_number object.group_loan_membership.member.id_number

   	if object.direction == FUND_TRANSFER_DIRECTION[:incoming] 
		json.direction_text				"Penambahan" 
	elsif object.direction == FUND_TRANSFER_DIRECTION[:outgoing]
		json.direction_text				"Penarikan" 
	end

	json.direction object.direction

end

