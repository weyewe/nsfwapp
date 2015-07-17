Ext.define('AM.view.operation.DeceasedClearance', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.deceasedclearanceProcess',
	 
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
				xtype : 'deceasedclearancelist',
				flex : 2
			}, 
			 
		]
});