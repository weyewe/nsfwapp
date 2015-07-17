Ext.define('AM.view.operation.memorialdetail.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.memorialdetaillist',

  	store: 'MemorialDetails', 
 

	initComponent: function() {
		this.columns = [
		 
			{
				xtype : 'templatecolumn',
				text : "Akun",
				flex : 2,
				tpl : '<b>{account_name}</b>' + "<br />" + "<br />"+ 
				 			"{description}"
			},
			
			{
				xtype : 'templatecolumn',
				text : "Case",
				flex : 1,
				tpl : '<b>{entry_case_text}</b>'  
			},
			{
				xtype : 'templatecolumn',
				text : "Jumlah",
				flex : 1,
				tpl : '<b>{amount}</b>'  
			}, 
			
			
			 
		];
		

		this.addObjectButton = new Ext.Button({
			text: 'Add',
			action: 'addObject',
			disabled : true 
		});
		
	 

		this.editObjectButton = new Ext.Button({
			text: 'Edit',
			action: 'editObject',
			disabled: true
		});
		
		this.deleteObjectButton = new Ext.Button({
			text: 'Delete',
			action: 'deleteObject',
			disabled: true
		});


		this.tbar = [this.addObjectButton,  this.editObjectButton, this.deleteObjectButton ]; 
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: 'Details {0} - {1} of {2}',
			emptyMsg: "No details" 
		});

		this.callParent(arguments);
	},
 
	loadMask	: true,
	 
	
	getSelectedObject: function() {
		return this.getSelectionModel().getSelection()[0];
	},
	
	enableAddButton: function(){
		this.addObjectButton.enable();
	},
	
	disableAddButton: function(){
		this.addObjectButton.disable();
	},

	enableRecordButtons: function() {
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
	},
	
	setObjectTitle : function(record){
		this.setTitle("Memorial: " + record.get("code"));
	}
});
