Ext.define('AM.model.TransactionDataDetail', {
  	extend: 'Ext.data.Model',
  	fields: [
 

    	{ name: 'id', type: 'int' },
    	{ name: 'account_name', type: 'string' },
			{ name: 'entry_case_text', type: 'string' } ,
			{ name: 'entry_case', type: 'int' } ,
			{ name: 'amount', type: 'int' } ,  // on start group loan
			{ name: 'description', type: 'string' }   
			
  	],

	 


   
  	idProperty: 'id' ,

		proxy: {
			url: 'api/transaction_data_details',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'transaction_data_details',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { transaction_data_detail : record.data };
				}
			}
		}
	
  
});
