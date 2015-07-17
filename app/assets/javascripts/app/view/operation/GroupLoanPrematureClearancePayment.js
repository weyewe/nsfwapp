Ext.define('AM.view.operation.GroupLoanPrematureClearancePayment', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.grouploanprematureclearancepaymentProcess',
	 
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
				xtype : 'grouploanprematureclearancepaymentlist',
				flex : 2
			}, 
			 
		]
});