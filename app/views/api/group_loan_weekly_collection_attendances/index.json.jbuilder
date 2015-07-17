json.success true 
json.total @total
json.group_loan_weekly_collection_attendances @objects do |object|
	json.id 								object.id 
	
	json.group_loan_weekly_collection_id object.group_loan_weekly_collection_id
	json.group_loan_membership_id object.group_loan_membership_id 
	json.group_loan_weekly_collection_week_number object.group_loan_weekly_collection.week_number 
	 
	
	json.member_name object.group_loan_membership.member.name
	json.attendance_status object.attendance_status
	json.payment_status object.payment_status
end

