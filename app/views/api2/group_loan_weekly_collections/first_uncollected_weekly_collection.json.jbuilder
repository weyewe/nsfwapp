json.success true 
json.total @total

json.group_loan_id @parent.id 
json.group_loan_weekly_collection_id @object.id 
json.week_number @object.week_number
json.group_name @parent.name
json.group_number @parent.group_number 
json.group_loan_weekly_collection_is_collected @object.is_collected  


json.group_loan_memberships @objects do |object|

	json.id 								object.id 


	json.member_name 			 			object.member.name 
	json.member_address		object.member.address
	json.member_id_number object.member.id_number 

	json.member_weekly_payment_amount object.group_loan_product.
											weekly_payment_amount

	json.weekly_collection_attendance_id  object.
											weekly_collection_attendance( @object ) .id

	json.weekly_collection_payment_status object.
											weekly_collection_attendance( @object ) .payment_status
	json.weekly_collection_attendance_status object.
											weekly_collection_attendance( @object ) .attendance_status



	if  object.weekly_collection_voluntary_savings_entry( @object ).nil?
		json.weekly_collection_voluntary_savings_entry_direction nil 
		json.weekly_collection_voluntary_savings_entry_amount nil 
		json.weekly_collection_voluntary_savings_entry_id nil 
	else
		json.weekly_collection_voluntary_savings_entry_direction  object.
																	weekly_collection_voluntary_savings_entry( @object ).direction 
	
		json.weekly_collection_voluntary_savings_entry_amount  object.
																	weekly_collection_voluntary_savings_entry( @object ).amount 
	
		json.weekly_collection_voluntary_savings_entry_id  object.
																	weekly_collection_voluntary_savings_entry( @object ).id 
	end 
end

  