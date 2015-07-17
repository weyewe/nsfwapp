Ext.define('AM.model.Branch', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'branch_id', type: 'int' },
    	{ name: 'name', type: 'string' },
			{ name: 'description', type: 'string' } ,
			{ name: 'address', type: 'string' } ,
			
			{ name: 'code', type: 'string' }     ,
			
  	],

	 


   
  	idProperty: 'id' ,

		proxy: {
			url: 'api/branches',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'branches',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { branch : record.data };
				}
			}
		}
	
  
});
