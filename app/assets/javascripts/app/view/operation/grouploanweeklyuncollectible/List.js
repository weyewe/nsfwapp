Ext.define('AM.view.operation.grouploanweeklyuncollectible.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploanweeklyuncollectiblelist',
  	store: 'GroupLoanWeeklyUncollectibles', 
 
 
	initComponent: function() {
		this.columns = [
		
			{
				xtype : 'templatecolumn',
				text : "Member",
				flex : 1,
				tpl : '<b>{group_loan_membership_member_name}</b>' + '<br />' + 
							'Nama: <b>{group_loan_membership_member_name}</b>' + '<br />' + 
							'Alamat: {group_loan_membership_member_address}'  
			},
			{ header: 'Minggu', dataIndex: 'group_loan_weekly_collection_week_number' , flex : 1 },
			{
				xtype : 'templatecolumn',
				text : "Jumlah",
				flex : 1,
				tpl : '<b>{amount}</b>' + '<br />' + 
							'Pokok: <b>{principal}</b>' + '<br />'  + '<br />'  + 
							'{clearance_case_text}'
			},
			
			{
				xtype : 'templatecolumn',
				text : "Status Pembayaran",
				flex : 1,
				tpl : 'Terkumpul: <b>{is_collected}</b>' + '<br />' + 
							'Terkonfirmasi: <b>{is_cleared}</b>'   
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
		
		this.collectObjectButton = new Ext.Button({
			text: 'Collect',
			action: 'collectObject',
			disabled: true
		});
		this.clearObjectButton = new Ext.Button({
			text: 'Clear',
			action: 'clearObject',
			disabled: true
		});
		
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton ,
		 					'-',
							this.collectObjectButton, this.clearObjectButton ];
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
	},
	
	disableAddButton : function(){
		this.addObjectButton.disable();
	},

	enableRecordButtons: function() {
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
		this.collectObjectButton.enable(); 
		this.clearObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
		this.collectObjectButton.disable(); 
		this.clearObjectButton.disable();
	}
});
