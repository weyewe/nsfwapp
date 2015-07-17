Ext.define('AM.view.operation.GroupLoanWeeklyUncollectible', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.grouploanweeklyuncollectibleProcess',
	 
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
				xtype : 'operationgrouploanList',
				flex : 1
			},
			{
				xtype : 'grouploanweeklyuncollectiblelist',
				flex : 2
			}, 
			 
		]
});