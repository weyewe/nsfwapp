Ext.define('AM.view.operation.GroupLoanRunAwayReceivable', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.grouploanrunawayreceivableProcess',
	 
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
				flex : 1
			},
			{
				xtype : 'grouploanrunawayreceivablelist',
				flex : 2
			}, 
			 
		]
});