Ext.define('AM.store.GroupLoanWeeklyCollectionAttendances', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.GroupLoanWeeklyCollectionAttendance'],
  	model: 'AM.model.GroupLoanWeeklyCollectionAttendance',
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
