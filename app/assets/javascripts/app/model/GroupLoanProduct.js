Ext.define('AM.model.GroupLoanProduct', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' },
			{ name: 'total_weeks', type: 'int' } ,
			{ name: 'principal', type: 'string' },
			{ name: 'interest', type: 'string' }  ,
			{ name: 'compulsory_savings', type: 'string' }  ,
			{ name: 'admin_fee', type: 'string' }     ,
			{ name : "weekly_payment_amount", type: 'string'},
			{ name: 'initial_savings', type: 'string' }  ,
			
			
  	],

	  

   
  	idProperty: 'id' ,

		proxy: {
			url: 'api/group_loan_products',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'group_loan_products',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { group_loan_product : record.data };
				}
			}
		}
	
  
});
