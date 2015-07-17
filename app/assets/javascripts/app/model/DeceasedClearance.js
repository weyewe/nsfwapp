Ext.define('AM.model.DeceasedClearance', {
  	extend: 'Ext.data.Model',
 
	 
		 
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'financial_product_id', type: 'int' },
			{ name: 'financial_product_name', type: 'string' },
			{ name: 'financial_product_type', type: 'string' },
			
    	{ name: 'principal_return', type: 'string' },
			{ name: 'additional_savings_account', type: 'string' },
			
			{ name: 'member_id', type: 'int' },
			{ name: 'member_name', type: 'string' },  
			{ name: 'donation', type: 'string'},
			
			//                  other proxy info
			
			{ name: 'is_insurance_claimable', type: 'boolean' },  
			{ name: 'is_confirmed', type: 'boolean' }, 
			{ name: 'is_insurance_claim_submitted', type: 'boolean' }, 
			{ name: 'is_insurance_claim_approved', type: 'boolean' }, 
			{ name: 'is_claim_received', type: 'boolean' },
			{ name: 'is_donation_disbursed', type: 'boolean' },  
  	],

  	idProperty: 'id' ,

		proxy: {
			url: 'api/deceased_clearances',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'deceased_clearances',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { deceased_clearance : record.data };
				}
			}
		}
	
  
});
