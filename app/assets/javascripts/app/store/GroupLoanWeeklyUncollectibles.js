Ext.define('AM.store.GroupLoanWeeklyUncollectibles', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.GroupLoanWeeklyUncollectible'],
  	model: 'AM.model.GroupLoanWeeklyUncollectible',
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
