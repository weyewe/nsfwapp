Ext.define('AM.view.operation.LoanTrail', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.loantrailProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
		// just the list
			{
				xtype : 'operationmemberList',
				flex : 1,
				showTotalSavingsAmount: false,
				showTotalLockedSavingsAmount: false,
				showTotalMembershipSavingsAmount: false
			},
			{
				xtype : 'loantraillist',
				// html : "this is awesome",
				flex : 1
			}, 
			 
		]
});