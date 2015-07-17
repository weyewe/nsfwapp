json.success true 
json.total @total
json.records @objects do |object|
	json.id 						object.id
	json.code 			object.code 
	json.customer_name 						object.customer.name 
end
