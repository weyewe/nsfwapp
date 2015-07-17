Ext.define('AM.model.SavingsEntry', {
  	extend: 'Ext.data.Model',
 
	 
		 
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'member_id', type: 'int' },
			{ name: 'member_name', type: 'string' },  
			{ name: 'member_id_number', type: 'string'},
			
			{ name: 'direction', type: 'int'},
			{ name: 'direction_text', type: 'string'},
			
			{ name: 'amount', type: 'string'},
			
			{ name: 'is_confirmed', type: 'boolean'},
			{ name: 'confirmed_at', type: 'string'},
			{ name: 'savings_status', type: 'int'},
			{ name: 'savings_status_text', type: 'string'}
  	],

  	idProperty: 'id' ,

		proxy: {
			url: 'api/savings_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'savings_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { savings_entry : record.data };
				}
			}
		}
	
  
});
