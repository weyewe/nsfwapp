Ext.define('AM.model.GroupLoanWeeklyCollection', {
  	extend: 'Ext.data.Model',
 
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'group_loan_id', type: 'int' },
			{ name: 'group_loan_name', type: 'string' } ,
			
			{ name: 'week_number', type: 'int' }   ,
			
			{ name: 'is_collected', type: 'boolean' }   ,
			{ name: 'collected_at', type: 'string' }  ,
			{ name: 'is_confirmed', type: 'boolean' }  ,
			{ name: 'confirmed_at', type: 'string' }  ,
			
			{ name: 'group_loan_weekly_uncollectible_count', type: 'int' }   				,
			{ name: 'group_loan_deceased_clearance_count', type: 'int' }            ,
			{ name: 'group_loan_run_away_receivable_count', type: 'int' }           ,
			{ name: 'group_loan_premature_clearance_payment_count', type: 'int' }   ,
			{ name: 'amount_receivable', type: 'string' }   ,
  	],

  	idProperty: 'id' ,

		proxy: {
			url: 'api/group_loan_weekly_collections',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'group_loan_weekly_collections',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { group_loan_weekly_collection : record.data };
				}
			}
		}
	
  
});
