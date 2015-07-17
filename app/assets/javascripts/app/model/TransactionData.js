Ext.define('AM.model.TransactionData', {
  	extend: 'Ext.data.Model',
  	fields: [

	 
    	{ name: 'id', type: 'int' },
    	{ name: 'transaction_datetime', type: 'string' },
			{ name: 'transaction_source_type', type: 'string' } ,
			{ name: 'description', type: 'string' } ,  // on start group loan
			{ name: 'code', type: 'string' }   
			
			
  	],

	 


   
  	idProperty: 'id' ,

		proxy: {
			url: 'api/transaction_datas',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'transaction_datas',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { transaction_data : record.data };
				}
			}
		}
	
  
});
