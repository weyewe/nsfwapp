Ext.define('AM.store.Employees', {
  	extend: 'Ext.data.Store',
	require : ['AM.model.Employee'],
  	model: 'AM.model.Employee',
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
