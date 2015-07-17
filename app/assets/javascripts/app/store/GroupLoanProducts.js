Ext.define('AM.store.GroupLoanProducts', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.GroupLoanProduct'],
  	model: 'AM.model.GroupLoanProduct',
  	// autoLoad: {start: 0, limit: this.pageSize},
		autoLoad : false, 
  	autoSync: false,
	pageSize : 40, 
	
	
		
		
	sorters : [
		{
			property	: 'id',
			direction	: 'DESC'
		}
	], 

	listeners: {

	} 
});
