Ext.define('AM.store.GroupLoanMemberships', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.GroupLoanMembership'],
  	model: 'AM.model.GroupLoanMembership',
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
