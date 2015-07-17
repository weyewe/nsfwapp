Ext.define('AM.store.GroupLoanPrematureClearancePayments', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.GroupLoanPrematureClearancePayment'],
  	model: 'AM.model.GroupLoanPrematureClearancePayment',
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
