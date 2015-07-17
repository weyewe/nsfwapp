Ext.define('AM.store.GroupLoanRunAwayReceivables', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.GroupLoanRunAwayReceivable'],
  	model: 'AM.model.GroupLoanRunAwayReceivable',
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
