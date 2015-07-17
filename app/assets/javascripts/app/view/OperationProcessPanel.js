Ext.define('AM.view.OperationProcessPanel', {
    extend: 'Ext.panel.Panel',
		alias : 'widget.operationProcessPanel',
    

		layout: {
        type : 'hbox',
        align: 'stretch'
    },
    
    items: [
			{
				bodyPadding: 5,
				xtype: 'operationProcessList',
				flex : 1
			}, 
      {
					flex :  6, 
          id   : 'operationWorksheetPanel', 
          bodyPadding: 0,
					layout : {
						type: 'fit'
					},
					items : [
						{
							xtype: 'operationDefault'
							 // : "Ini adalah tampilan operation. Anda dapat membuat operation baru, atau menambah customer",
						}
					]
      }
    ]
 
});
