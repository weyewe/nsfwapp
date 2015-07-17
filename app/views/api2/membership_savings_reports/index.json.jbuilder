json.success true 
json.total @total
json.members @objects do |object|
	json.id 								object.id 




  json.id_number            object.id_number
  json.name             object.name


  json.membership_savings_entries object.savings_entries.where(
                :savings_status => SAVINGS_STATUS[:membership],
                :is_confirmed => true ) do |membership_savings|

    json.id         membership_savings.id 
    json.direction      membership_savings.direction
    json.amount       membership_savings.amount 

    json.confirmed_at   format_date_friendly( membership_savings.confirmed_at )
  end





end

  