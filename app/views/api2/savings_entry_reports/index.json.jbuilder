json.success true 
json.total @total
json.savings_entries @objects do |object|
	json.id 								object.id 

  json.amount   object.amount
  json.direction object.direction
  json.confirmed_at   format_date_friendly( object.confirmed_at )


  json.member_name object.member.name
  json.member_id_number object.member.id_number





end

  