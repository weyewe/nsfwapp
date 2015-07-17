Ext.define('AM.store.TransactionDataDetails', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.TransactionDataDetail'],
  	model: 'AM.model.TransactionDataDetail',
  	// autoLoad: {start: 0, limit: this.pageSize},
		autoLoad : false, 
  	autoSync: false,
	pageSize : 20, 
	
	
		
		
	sorters : [
		{
			property	: 'entry_case',
			direction	: 'ASC'
		}
	], 

	listeners: {

	} 
});
