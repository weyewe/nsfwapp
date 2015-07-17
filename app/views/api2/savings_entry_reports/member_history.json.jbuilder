json.success true 
json.total @total
json.savings_entries @objects do |object|
	json.id 								object.id 

  json.amount   object.amount
  json.direction object.direction
  json.confirmed_at   format_date_friendly( object.confirmed_at )
  json.created_at 	format_date_friendly( object.created_at )
  json.financial_product_type object.financial_product_type
  json.financial_product_id  object.financial_product_id


 



end

  