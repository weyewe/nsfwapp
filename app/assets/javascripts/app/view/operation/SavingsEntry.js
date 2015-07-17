Ext.define('AM.view.operation.SavingsEntry', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.savingsentryProcess',
	 
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
				showTotalSavingsAmount: true,
				showTotalLockedSavingsAmount: true,
				showTotalMembershipSavingsAmount: true
			},
			{
				xtype : 'savingsentrylist',
				flex : 1
			}, 
			 
		]
});