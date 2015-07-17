
json.success true 
json.total @total
 

json.transaction_datas @objects do |object|


	json.id 								object.id 
	json.transaction_datetime 			 format_date_friendly( object.transaction_datetime )   
	json.description 			 object.description
	json.transaction_source_type 			 object.transaction_source_type
	
	json.code 					 object.code  
	
	
end
