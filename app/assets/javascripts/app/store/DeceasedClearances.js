Ext.define('AM.store.DeceasedClearances', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.DeceasedClearance'],
  	model: 'AM.model.DeceasedClearance',
  	// autoLoad: {start: 0, limit: this.pageSize},
		autoLoad : false, 
  	autoSync: false,
	pageSize : 40, 
	
	
	sorters : [
		{
			property	: 'id',
			direction	: 'ASC'
		}
	], 

	listeners: {

	} 
});
