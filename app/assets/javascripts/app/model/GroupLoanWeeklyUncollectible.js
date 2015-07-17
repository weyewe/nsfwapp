Ext.define('AM.model.GroupLoanWeeklyUncollectible', {
  	extend: 'Ext.data.Model',
 
	 
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'group_loan_id', type: 'int' },
			{ name: 'group_loan_name', type: 'string' },
    	{ name: 'group_loan_weekly_collection_id', type: 'int' },
			{ name: 'group_loan_weekly_collection_week_number', type: 'int' },
			
			{ name: 'group_loan_membership_id', type: 'int' },
			{ name: 'group_loan_membership_member_name', type: 'string' },
			{ name: 'group_loan_membership_member_address', type: 'string' },
			
			{ name: 'amount', type: 'string' }   ,
			{ name: 'principal', type: 'string' }  ,
			{ name: 'is_collected', type: 'boolean' }  ,
			{ name: 'collected_at', type: 'string' }  ,
			
			{ name: 'is_cleared', type: 'boolean' }   				,
			{ name: 'cleared_at', type: 'string' } ,
			{ name: 'clearance_case', type: 'int' },
			{ name: 'clearance_case_text', type: 'string' }                             
  	],

  	idProperty: 'id' ,

		proxy: {
			url: 'api/group_loan_weekly_uncollectibles',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'group_loan_weekly_uncollectibles',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { group_loan_weekly_uncollectible : record.data };
				}
			}
		}
	
  
});
