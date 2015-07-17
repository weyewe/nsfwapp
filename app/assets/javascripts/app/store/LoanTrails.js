Ext.define('AM.store.LoanTrails', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.LoanTrail'],
  	model: 'AM.model.LoanTrail',
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
