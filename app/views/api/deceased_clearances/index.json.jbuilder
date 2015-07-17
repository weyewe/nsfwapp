json.success true 
json.total @total

 
json.deceased_clearances @objects do |object|
	json.id 								object.id 
	json.financial_product_id 			 						object.financial_product_id
	json.financial_product_type 			 						object.financial_product_type
	json.financial_product_name 			 object.financial_product.name 
	
	json.principal_return 							object.principal_return
	json.donation				object.donation
	json.additional_savings_account 						object.additional_savings_account
	
	json.member_id						 object.member_id
	json.member_name 					 object.member.name	
	
	
	json.is_insurance_claimable 						 object.is_insurance_claimable
	json.is_confirmed 											 object.is_confirmed
	json.is_insurance_claim_submitted 			 object.is_insurance_claim_submitted
	json.is_insurance_claim_approved 				 object.is_insurance_claim_approved
	json.is_claim_received 									 object.is_claim_received
	json.is_donation_disbursed 							 object.is_donation_disbursed
 
end
