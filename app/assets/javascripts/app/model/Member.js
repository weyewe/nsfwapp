Ext.define('AM.model.Member', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' },
			{ name: 'address', type: 'string' } ,
			{ name: 'id_number', type: 'string' } ,
			
			{ name: 'total_savings_account', type: 'string' }     ,
			{ name: 'total_locked_savings_account', type: 'string' }     ,
			{ name: 'total_membership_savings', type: 'string' }     ,
			
			{ name: 'is_run_away', type: 'boolean' }    ,
			{ name: 'is_deceased', type: 'boolean' }    ,
			
			{ name: 'id_card_number', type: 'string' }     ,
			{ name: 'birthday_date', type: 'string' }     ,
			{ name: 'is_data_complete', type: 'boolean' }     ,
			{ name: 'rt', type: 'int' }     ,
			
			{ name: 'rw', type: 'int' }     ,
			{ name: 'village', type: 'string' }     ,
			{ name: 'active_group_loan_name', type: 'string' }     ,
  	],

	 


   
  	idProperty: 'id' ,

		proxy: {
			url: 'api/members',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'members',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { member : record.data };
				}
			}
		}
	
  
});
