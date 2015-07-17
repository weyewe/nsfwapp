Ext.define('AM.model.Account', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },

			{ name: 'parent_id', type: 'int' },
			{ name: 'parent_name', type: 'string' },
      { name: 'name' },
			{	name : 'code'}, 
     
			{name : 'account_case' , type : 'int'},  // ledger or group 
			{name : 'account_case_text' , type : 'string'},
			
			{name : 'normal_balanec' , type : 'int'},
			{name : 'normal_balance_text' , type : 'string'},  // debit or credit 
			
			
  	],

	 


   
  	idProperty: 'id' ,

		proxy: {
			url: 'api/accounts',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'accounts',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { account : record.data };
				}
			}
		}
	
  
});
