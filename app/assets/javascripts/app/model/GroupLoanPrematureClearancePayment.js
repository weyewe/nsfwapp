Ext.define('AM.model.GroupLoanPrematureClearancePayment', {
  	extend: 'Ext.data.Model',
 
	 
		// 	
		// params[:group_loan_id]
		//     params[:group_loan_membership_id]
		//     params[:group_loan_weekly_collection_id]
		
		
		
 

  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'group_loan_id', type: 'int' },
			{ name: 'group_loan_name', type: 'string' },
			
    	{ name: 'group_loan_weekly_collection_id', type: 'int' },
			{ name: 'group_loan_weekly_collection_week_number', type: 'int' },
			
			{ name: 'group_loan_membership_id', type: 'int' },
			{ name: 'group_loan_membership_member_name', type: 'string' },
			{ name: 'group_loan_membership_member_address', type: 'string' },
			{ name: 'group_loan_membership_deactivation_week_number', type: 'int' },
			
			
			{ name: 'total_principal_return', type: 'string' }   ,
			{ name: 'run_away_weekly_resolution_bail_out', type: 'string' }   ,
			{ name: 'run_away_end_of_cycle_resolution_bail_out', type: 'string' }   ,
			{ name: 'available_compulsory_savings', type: 'string' }   ,
			{ name: 'remaining_compulsory_savings', type: 'string' }   ,
			
			
			
			{ name: 'amount', type: 'string' }   ,
			// { name: 'remaining_compulsory_savings', type: 'string' }  ,
			
			{ name: 'is_confirmed', type: 'boolean' }   		                           
  	],

  	idProperty: 'id' ,

		proxy: {
			url: 'api/group_loan_premature_clearance_payments',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'group_loan_premature_clearance_payments',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { group_loan_premature_clearance_payment : record.data };
				}
			}
		}
	
  
});
