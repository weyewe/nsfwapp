Ext.define('AM.model.GroupLoanWeeklyCollectionVoluntarySavingsEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'group_loan_weekly_collection_id', type: 'int' },
			{ name: 'group_loan_membership_id', type: 'int' } ,
			
			{ name: 'amount', type: 'string ' }  , 
			{ name: 'member_name', type: 'string' }   ,
			{ name: 'member_id_number', type: 'string' }  ,  
			  

		  	{ name: 'direction', type: 'int'},
			{ name: 'direction_text', type: 'string'},
			
  	],

	 


   
  	idProperty: 'id' ,

		proxy: {
			url: 'api/group_loan_weekly_collection_voluntary_savings_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'group_loan_weekly_collection_voluntary_savings_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { group_loan_weekly_collection_voluntary_savings_entry : record.data };
				}
			}
		}
	
  
});
