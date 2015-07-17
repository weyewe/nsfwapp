json.success true 
json.total @total
json.group_loan_weekly_collections @objects do |object|
	json.id 								object.id 
	json.group_loan_id 			 object.group_loan_id   
	json.group_loan_name 			 object.group_loan.name  
	
	json.week_number 							object.week_number 
	json.is_collected				object.is_collected 
	json.is_confirmed				object.is_confirmed
	
	json.collected_at 	format_date_friendly( object.collected_at ) 
	json.confirmed_at  format_date_friendly( object.confirmed_at ) 
	
	json.amount_receivable object.amount_receivable
	 
	
	json.group_loan_weekly_uncollectible_count 				object.group_loan_weekly_uncollectible_count
	json.group_loan_deceased_clearance_count 					object.group_loan_deceased_clearance_count
	json.group_loan_run_away_receivable_count 				object.group_loan_run_away_receivable_count
	json.group_loan_premature_clearance_payment_count object.group_loan_premature_clearance_payment_count
end

  