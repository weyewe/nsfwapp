Ext.define('AM.store.GroupLoanWeeklyCollections', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.GroupLoanWeeklyCollection'],
  	model: 'AM.model.GroupLoanWeeklyCollection',
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
