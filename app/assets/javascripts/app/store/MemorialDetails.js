Ext.define('AM.store.MemorialDetails', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.MemorialDetail'],
  	model: 'AM.model.MemorialDetail',
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
