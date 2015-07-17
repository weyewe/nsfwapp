Ext.define('AM.store.GroupLoans', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.GroupLoan'],
  	model: 'AM.model.GroupLoan',
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
