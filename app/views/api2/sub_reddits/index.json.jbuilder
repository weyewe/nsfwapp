json.success true 
json.total @total
json.sub_reddits @objects do |object|
	json.id 								object.id 
	json.name 			 			object.name
	json.image_url 			 			object.image_url

end

  