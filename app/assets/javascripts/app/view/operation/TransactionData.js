Ext.define('AM.view.operation.TransactionData', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.transactiondataProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		
		items : [
			{
				xtype : 'transactiondatalist' ,
				flex : 1 //,
				// html : 'hahaha'
			},
			{
				xtype :'transactiondatadetaillist',
				// html : "This is gonna be the price_rule",
				flex : 1
			} 
		],
 
});