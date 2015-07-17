json.success true 
json.total @total

 
json.group_loan_run_away_receivables @objects do |object|
	json.id 								object.id 
	
	json.group_loan_id 				object.group_loan_id
	json.group_loan_name 			object.group_loan.name 
	
	json.member_id 							object.member_id
	json.member_name 						object.member.name
	
	json.group_loan_weekly_collection_id object.group_loan_weekly_collection_id 
	json.group_loan_weekly_collection_week_number object.group_loan_weekly_collection.week_number  
	
	json.group_loan_membership_id object.group_loan_membership_id 
	
	json.payment_case object.payment_case 
	
	if object.payment_case  ==  GROUP_LOAN_RUN_AWAY_RECEIVABLE_PAYMENT_CASE[:weekly]
		json.payment_case_text  "Mingguan"
	elsif  object.clearance_case  ==  GROUP_LOAN_RUN_AWAY_RECEIVABLE_PAYMENT_CASE[:end_of_cycle]
		json.payment_case_text  "Pemotongan Tabungan Wajib"
	end
end
