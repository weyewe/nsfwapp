Ext.define('AM.model.GroupLoanRunAwayReceivable', {
  	extend: 'Ext.data.Model',
 
 
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'group_loan_id', type: 'int' },
			{ name: 'group_loan_name', type: 'string' },
			
    	{ name: 'member_id', type: 'int' },
			{ name: 'member_name', type: 'string' },
			
			{ name: 'group_loan_weekly_collection_id', type: 'int' },
			{ name: 'group_loan_weekly_collection_week_number', type: 'int' },  
			{ name: 'group_loan_membership_id', type: 'int'},
			
			{ name: 'payment_case', type: 'int' },  
			{ name: 'payment_case_text', type: 'string' },   
  	],

  	idProperty: 'id' ,

		proxy: {
			url: 'api/group_loan_run_away_receivables',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'group_loan_run_away_receivables',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { group_loan_run_away_receivable : record.data };
				}
			}
		}
	
  
});
