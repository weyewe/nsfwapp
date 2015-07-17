json.success true 

json.group_loans @objects do |object|
 

    
	json.group_number 			object[0]
	json.name 			 			object[1]
	json.disbursed_at 			 			object[2]
	json.total_active_glm 			 			object[3] 
	json.total_weekly_collections 			 			object[4]
	json.total_paid_weekly_collections 			 			object[5]
	json.last_collection_date 			 			object[6]
	json.next_collection_amount 			 			object[7]

end

  

