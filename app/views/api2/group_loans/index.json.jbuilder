json.success true 
json.total @total
json.group_loans @objects do |object|
	json.id 								object.id 
	json.name 			 			object.name
	json.group_number 			 			object.group_number

end

  