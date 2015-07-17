json.success true 
json.total @total
json.images @objects do |object|
	json.id 								object.id 
	json.sub_reddit_id 			 			object.sub_reddit_id
	json.main_url 			 			object.main_url

end

  