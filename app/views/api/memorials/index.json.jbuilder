
json.success true 
json.total @total
 

json.memorials @objects do |object|

	json.id 								object.id 
	json.transaction_datetime 			 format_date_friendly( object.transaction_datetime )   
	json.description 			 object.description
	json.is_confirmed 			 object.is_confirmed
	
	json.confirmed_at 						format_date_friendly( 	object.confirmed_at ) 
	
	json.code 					 object.code
	
	json.is_deleted 						object.is_deleted 
	json.deleted_at 	format_date_friendly( 	object.deleted_at ) 
	
	
end
