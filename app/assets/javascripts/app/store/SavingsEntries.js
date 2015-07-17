Ext.define('AM.store.SavingsEntries', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.SavingsEntry'],
  	model: 'AM.model.SavingsEntry',
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
