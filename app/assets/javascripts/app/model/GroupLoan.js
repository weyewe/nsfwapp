Ext.define('AM.model.GroupLoan', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'number_of_meetings', type: 'int' },
			{ name: 'number_of_collections', type: 'int' } ,
			{ name: 'total_members_count', type: 'int' } ,  // on start group loan
			{ name: 'name', type: 'string' }   ,
			{ name: 'is_started', type: 'boolean' }   ,
			{ name: 'is_loan_disbursed', type: 'boolean' }   ,
			{ name: 'is_closed', type: 'boolean' }   ,
			{ name: 'is_compulsory_savings_withdrawn', type: 'boolean' }  ,
			
			{ name: 'started_at', type: 'string' }  ,
			{ name: 'disbursed_at', type: 'string' }  ,
			{ name: 'closed_at', type: 'string' }  ,
			{ name: 'compulsory_savings_withdrawn_at', type: 'string' },
			
			//  analysis
			{ name: 'start_fund', type: 'string' },
			{ name: 'group_number', type: 'string' },
			{ name: 'disbursed_group_loan_memberships_count', type: 'int' },
			{ name: 'disbursed_fund', type: 'string' },
			{ name: 'non_disbursed_fund', type: 'string' },
			{ name: 'active_group_loan_memberships_count', type: 'int' },
			
			{ name: 'compulsory_savings_return_amount', type: 'string' },
			{ name: 'bad_debt_allowance', type: 'string' },
			{ name: 'bad_debt_expense', type: 'string' },
			{ name: 'premature_clearance_deposit', type: 'string' },
			{ name: 'expected_revenue_from_run_away_member_end_of_cycle_resolution', type: 'string' },
			{ name: 'total_compulsory_savings_pre_closure', type: 'string' },
			
			
  	],

	 


   
  	idProperty: 'id' ,

		proxy: {
			url: 'api/group_loans',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'group_loans',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { group_loan : record.data };
				}
			}
		}
	
  
});
