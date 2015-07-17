json.success true 
json.total @total
json.records @objects do |object|
	json.group_loan_membership_id 								object.id 
	json.member_name 			 object.member.name   
	json.member_id_number 			 object.member.id_number  
	
end

