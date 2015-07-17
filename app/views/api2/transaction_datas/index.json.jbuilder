json.success true 
json.total @total


json.transaction_datas @objects do |object|

	json.id 								object.id 


	json.description 			 			object.description
	json.transaction_datetime			format_date_friendly( object.transaction_datetime ) 

	json.transaction_data_details object.transaction_data_details do |tdd|
		json.entry_case 		tdd.entry_case
		json.account_name		tdd.account.name 
		json.amount			tdd.amount 
	end
end

  