json.success true 
json.total @total
json.loan_trails @objects do |object|
 

	json.id 								object.id 
	json.group_loan_id 			 object.group_loan_id   
	json.group_loan_name 							object.group_loan.name  
	json.group_loan_group_number 							object.group_loan.group_number  
	
	json.group_loan_product_id				object.group_loan_product_id 
	json.group_loan_product_name				object.group_loan_product.name
	json.group_loan_product_principal				object.group_loan_product.principal
	json.group_loan_product_interest				object.group_loan_product.interest
	json.group_loan_product_compulsory_savings				object.group_loan_product.compulsory_savings
	json.group_loan_product_admin_fee				object.group_loan_product.admin_fee
	json.group_loan_product_total_weeks				object.group_loan_product.total_weeks
	
	
	json.member_id  						object.member_id
	json.member_name 						object.member.name
	json.member_id_number 			object.member.id_number 
	json.member_address 				object.member.address
	
	json.total_compulsory_savings object.total_compulsory_savings.to_s 
	
	json.is_active object.is_active
	
	json.deactivation_case object.deactivation_case
	json.deactivation_case_name object.deactivation_case_name 

	json.group_loan_disbursed_at  format_date_friendly( object.group_loan.disbursed_at ) 
	
	
	
end
