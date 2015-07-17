Ext.define('AM.store.Branches', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.Branch'],
  	model: 'AM.model.Branch',
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
