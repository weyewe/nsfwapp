json.success true 
json.total @total
json.group_loans @objects do |object|
	json.id 								object.id 
	json.name 			 												object.name   
	json.number_of_meetings 								object.number_of_meetings 
	json.number_of_collections							object.number_of_collections 
	json.total_members_count								object.total_members_count
	
	json.group_number                    object.group_number 
	
	json.is_started 												object.is_started
	json.started_at 												format_date_friendly( object.started_at )
	json.is_loan_disbursed 									object.is_loan_disbursed
	json.disbursed_at 											format_date_friendly( object.disbursed_at )
	json.is_closed 													object.is_closed
	json.closed_at 													format_date_friendly( object.closed_at ) 
	json.is_compulsory_savings_withdrawn 		object.is_compulsory_savings_withdrawn
	json.compulsory_savings_withdrawn_at	 	format_date_friendly( object.compulsory_savings_withdrawn_at )
	
	
	json.start_fund 														object.start_fund
	json.disbursed_group_loan_memberships_count object.disbursed_group_loan_memberships_count
	json.disbursed_fund													object.disbursed_fund
	json.non_disbursed_fund											object.non_disbursed_fund
	json.active_group_loan_memberships_count		object.active_group_loan_memberships.count
	
	json.compulsory_savings_return_amount		object.compulsory_savings_return_amount
	json.bad_debt_allowance 								object.bad_debt_allowance
	json.bad_debt_expense										object.bad_debt_expense
	
	json.premature_clearance_deposit										object.premature_clearance_deposit
	json.expected_revenue_from_run_away_member_end_of_cycle_resolution object.expected_revenue_from_run_away_member_end_of_cycle_resolution
	json.total_compulsory_savings_pre_closure object.total_compulsory_savings_pre_closure
end
