json.success true 
json.total @total
json.group_loan_weekly_collection_report_details @objects do |object|
	json.id 								object.id 
	json.collected_at 			 			object.collected_at.to_s  # this is in utc
	json.confirmed_at 			 			object.confirmed_at.to_s 
	json.week_number		object.week_number

end

  