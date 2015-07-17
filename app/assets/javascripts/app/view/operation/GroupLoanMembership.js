Ext.define('AM.view.operation.GroupLoanMembership', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.grouploanmembershipProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
		// list of group loan.. just the list.. no CRUD etc
			{
				xtype : 'operationgrouploanList',
				flex : 1
			},
			
			{
				xtype : 'grouploanmembershiplist',
				flex : 2
			}, 
		]
});