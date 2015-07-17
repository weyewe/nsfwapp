
json.success true 
json.total @total
json.employees @objects do |object|
	json.id 								object.id  
	json.branch_id 								object.branch.id  
	json.branch_code								object.branch.code  
 
	
	json.name object.name
	json.description object.description
	
	json.code object.code
	
end




 