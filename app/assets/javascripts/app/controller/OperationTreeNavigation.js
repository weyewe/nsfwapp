/*
	Control the operationProcessList.
	
	For the personal reporting, we want to extract script from the server and execute it. 
*/
Ext.define("AM.controller.OperationTreeNavigation", {
	extend : "Ext.app.Controller",
	views : [
		"operation.OperationProcessList"
	],

	 
	
	refs: [
		{
			ref: 'operationProcessList',
			selector: 'operationProcessList'
		} ,
		{
			ref : 'worksheetPanel',
			selector : '#operationWorksheetPanel'
		}
	],
	 
	init : function( application ) {
		var me = this; 
		
		 
		me.control({
			"operationProcessList" : {
				'select' : this.onTreeRecordSelected
			} 
			
		});
		
	},
	
	onTreeRecordSelected : function( me, record, item, index, e ){
		if (!record.isLeaf()) {
			return;
		}

		this.setActiveExample( record.get('viewClass'), record.get('text'));
	},
	
	setActiveExample: function(className, title) {
      var worksheetPanel = this.getWorksheetPanel();
      
      worksheetPanel.setTitle(title);

      worksheet = Ext.create(className);
      worksheetPanel.removeAll();

      worksheetPanel.add(worksheet);
  }
});