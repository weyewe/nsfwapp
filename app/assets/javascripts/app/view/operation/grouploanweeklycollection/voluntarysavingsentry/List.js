Ext.define('AM.view.operation.grouploanweeklycollection.voluntarysavingsentry.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploanweeklycollectionvoluntarysavingsentrylist',

  	store: 'GroupLoanWeeklyCollectionVoluntarySavingsEntries', 
 
 
	initComponent: function() {
		this.columns = [
			
		 
			{ header: 'Member', dataIndex: 'member_name'   },
			
			
			

			{ header: 'Status', dataIndex: 'direction_text'   },
			{
				xtype : 'templatecolumn',
				text : "Jumlah",
				sortable : false,
				flex : 1,
				tpl : '<b>{amount}</b>'   
			},
			
			
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add',
			action: 'addObject',
			disabled: true
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
 


		this.tbar = [ this.addObjectButton, this.editObjectButton, this.deleteObjectButton  ];
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: '{0} - {1} of {2}',
			emptyMsg: "0" 
		});

		this.callParent(arguments);
	},
 
	loadMask	: true,
	
	getSelectedObject: function() {
		return this.getSelectionModel().getSelection()[0];
	},
	
	 

	enableRecordButtons: function() {
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
	}
});
