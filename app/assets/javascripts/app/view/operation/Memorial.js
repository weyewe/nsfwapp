Ext.define('AM.view.operation.Memorial', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.memorialProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		
		items : [
			{
				xtype : 'memoriallist' ,
				flex : 1 //,
				// html : 'hahaha'
			},
			{
				xtype :'memorialdetaillist',
				// html : "This is gonna be the price_rule",
				flex : 1
			} 
		],
 
});