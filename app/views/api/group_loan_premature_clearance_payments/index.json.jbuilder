json.success true 
json.total @total
json.group_loan_premature_clearance_payments @objects do |object|
	json.id 								object.id 
	json.group_loan_weekly_collection_id 			 						object.group_loan_weekly_collection_id
	json.group_loan_weekly_collection_week_number 			 object.group_loan_weekly_collection.week_number 
	
	json.group_loan_id 							object.group_loan_id
	json.group_loan_name 						object.group_loan.name 
	
	json.group_loan_membership_id			 object.group_loan_membership.id
	json.group_loan_membership_member_name 			 object.group_loan_membership.member.name
	json.group_loan_membership_member_id_number 			 object.group_loan_membership.member.id_number
	json.group_loan_membership_member_address 			 object.group_loan_membership.member.address
	
	 
	json.total_principal_return											object.total_principal_return
	json.run_away_weekly_resolution_bail_out				object.run_away_weekly_resolved_bail_out_contribution
	json.run_away_end_of_cycle_resolution_bail_out  object.run_away_end_of_cycle_resolved_bail_out_contribution	
	
	json.available_compulsory_savings 							object.available_compulsory_savings
	json.remaining_compulsory_savings			object.remaining_compulsory_savings
	json.amount 							object.amount 
	
	json.is_confirmed					object.is_confirmed 
	
 
end
