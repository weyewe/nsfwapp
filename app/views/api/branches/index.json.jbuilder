
json.success true 
json.total @total
json.branches @objects do |object|
	json.id 								object.id  
 
	
	json.name object.name
	json.address object.address
	json.description object.description
	
	json.code object.code
	
end




 