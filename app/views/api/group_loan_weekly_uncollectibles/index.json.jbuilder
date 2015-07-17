json.success true 
json.total @total
json.group_loan_weekly_uncollectibles @objects do |object|
	json.id 								object.id 
	json.group_loan_weekly_collection_id 			 						object.group_loan_weekly_collection_id
	json.group_loan_weekly_collection_week_number 			 object.group_loan_weekly_collection.week_number 
	
	json.group_loan_id 							object.group_loan_id
	json.group_loan_name 						object.group_loan.name 
	
	json.group_loan_membership_id			 object.group_loan_membership.id
	json.group_loan_membership_member_name 			 object.group_loan_membership.member.name
	json.group_loan_membership_member_id_number 			 object.group_loan_membership.member.id_number
	json.group_loan_membership_member_address 			 object.group_loan_membership.member.address
	
	 
	json.amount 							object.amount 
	json.principal						object.principal
	
	json.is_collected					object.is_collected
	json.collected_at					object.collected_at
	
	json.is_cleared						object.is_cleared
	json.cleared_at						object.cleared_at 
	
	json.clearance_case object.clearance_case 
	
	if object.clearance_case  ==  UNCOLLECTIBLE_CLEARANCE_CASE[:end_of_cycle]
		json.clearance_case_text  "Pemotongan Tabungan Wajib"
	elsif  object.clearance_case  ==  UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
		json.clearance_case_text  "Tunai"
	end
end
