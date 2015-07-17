Ext.define('AM.view.operation.savingsentry.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.savingsentrylist',
  	store: 'SavingsEntries', 
 
 		// sortable : false,
		// defaults: {
		// 	sortable: false
		// 	// hidden: true,
		// 	// 		            width: 100
		// },
		
	initComponent: function() {
		this.columns = [
		
			{ header: 'ID', dataIndex: 'id' , flex : 1, sortable: false },
			
			{
				xtype : 'templatecolumn',
				text : "Jumlah",
				sortable: false, 
				flex : 2,
				tpl : '<b>{savings_status_text}</b>' + '<br />'  + '<br />'  +
							'<b>{amount}</b>' + '<br />'  + '<br />'  + 
							'Kondisi: <b>{direction_text}</b>' 
			},
			{
				xtype : 'templatecolumn',
				text : "Status",
				sortable: false, 
				flex : 2,
				tpl : 'Konfirmasi: <b>{is_confirmed}</b>'  + '<br />' + 
							'Tanggal Konfirm: {confirmed_at} '
			},
			 
		];
	 
		// this.defaults = {
		// 	sortable : false
		// };

		this.addObjectButton = new Ext.Button({
			text: 'Add Voluntary',
			action: 'addObject',
			disabled: true
		});
		
		this.addLockedObjectButton = new Ext.Button({
			text: 'Add Locked',
			action: 'addLockedObject',
			disabled: true
		});
		
		this.addMembershipObjectButton = new Ext.Button({
			text: 'Add Membership',
			action: 'addMembershipObject',
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
		
		this.confirmObjectButton = new Ext.Button({
			text: 'Confirm',
			action: 'confirmObject',
			disabled: true 
		});
		
		this.unconfirmObjectButton = new Ext.Button({
			text: 'Unconfirm',
			action: 'unconfirmObject',
			disabled: true,
			hidden : true 
		});
		
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});



		this.tbar = [this.addObjectButton, 
									this.addLockedObjectButton,
									this.addMembershipObjectButton,
									'->',
									this.editObjectButton, this.deleteObjectButton ,	
									'-',
									this.confirmObjectButton,
									this.unconfirmObjectButton ];
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: 'Displaying topics {0} - {1} of {2}',
			emptyMsg: "No topics to display" 
		});

		this.callParent(arguments);
	},
  
	loadMask	: true,
	
	getSelectedObject: function() {
		return this.getSelectionModel().getSelection()[0];
	},
	
	enableAddButton: function(){
		this.addObjectButton.enable();
		this.addLockedObjectButton.enable();
		this.addMembershipObjectButton.enable();
	},
	
	disableAddButton : function(){
		this.addObjectButton.disable();
		this.addLockedObjectButton.disable();
		this.addMembershipObjectButton.disable();
	},

	enableRecordButtons: function() {
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
		this.confirmObjectButton.enable();
		this.unconfirmObjectButton.enable();
		
		selectedObject = this.getSelectedObject();
		if( selectedObject && selectedObject.get("is_confirmed") == true ){
			this.confirmObjectButton.hide();
			this.unconfirmObjectButton.show();
		}else{
			this.confirmObjectButton.show();
			this.unconfirmObjectButton.hide();
		}
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
		this.confirmObjectButton.disable();
		this.unconfirmObjectButton.disable();
	}
});
