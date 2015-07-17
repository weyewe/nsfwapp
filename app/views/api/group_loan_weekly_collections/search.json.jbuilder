json.success true 
json.total @total
json.records @objects do |object|
	json.id 						object.id
	json.week_number 			object.week_number  
end
