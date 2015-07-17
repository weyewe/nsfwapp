Ext.define('AM.store.GroupLoanWeeklyCollectionVoluntarySavingsEntries', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.GroupLoanWeeklyCollectionVoluntarySavingsEntry'],
  	model: 'AM.model.GroupLoanWeeklyCollectionVoluntarySavingsEntry',
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
