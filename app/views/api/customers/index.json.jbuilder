json.success true 
json.total @total
json.projects @objects do |object|
	json.id 								object.id 
	json.id_number 			 object.id_number   
	json.name 							object.name 
	json.address				object.address 
end
