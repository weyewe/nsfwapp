json.success true 
json.total @total
json.records @objects do |object|
	json.id 										object.id
	json.member_name 						object.member.name  
	json.member_id_number 			object.member.id_number
	json.group_loan_id 					object.group_loan_id
	
end

 