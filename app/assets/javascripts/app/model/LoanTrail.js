Ext.define('AM.model.LoanTrail', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'group_loan_id', type: 'int' },
			{ name: 'group_loan_name', type: 'string' } ,
			{ name: 'group_loan_group_number', type: 'string' } ,
			{ name: 'group_loan_disbursed_at', type: 'string' } ,
			
			{ name: 'group_loan_product_id', type: 'int' }   ,
			{ name: 'group_loan_product_name', type: 'string' }   ,
			{ name: 'group_loan_product_principal', type: 'string' }  ,
			{ name: 'group_loan_product_interest', type: 'string' }  ,
			{ name: 'group_loan_product_compulsory_savings', type: 'string' }  ,
			{ name: 'group_loan_product_admin_fee', type: 'string' }  ,
			{ name: 'group_loan_product_total_weeks', type: 'int' }  ,
			
			
			
			{ name: 'member_id', type: 'int' }   ,
			{ name: 'member_name', type: 'string' }   ,
			{ name: 'member_id_number', type: 'string' }  , 
			{ name: 'member_address', type: 'string' }  ,   
			
			{ name: 'total_compulsory_savings', type: 'string' }  ,
			
			
			{ name: 'is_active', type: 'boolean' }  ,
			{ name: 'deactivation_case', type: 'int' }  ,
			{ name: 'deactivation_case_name', type: 'string' }  ,
			
  	],

	 


   
  	idProperty: 'id' ,

		proxy: {
			url: 'api/loan_trails',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'loan_trails',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { loan_trail : record.data };
				}
			}
		}
	
  
});
