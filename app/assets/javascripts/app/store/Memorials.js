Ext.define('AM.store.Memorials', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.Memorial'],
  	model: 'AM.model.Memorial',
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
