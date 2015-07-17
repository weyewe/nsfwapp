Ext.define('AM.store.TransactionDatas', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.TransactionData'],
  	model: 'AM.model.TransactionData',
  	// autoLoad: {start: 0, limit: this.pageSize},
		autoLoad : false, 
  	autoSync: false,
	pageSize : 20, 
	
	
		
		
	sorters : [
		{
			property	: 'id',
			direction	: 'DESC'
		}
	], 

	listeners: {

	} 
});
