Ext.define('AM.store.Members', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.Member'],
  	model: 'AM.model.Member',
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
