Ext.define('AM.view.operation.grouploanrunawayreceivable.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploanrunawayreceivablelist',
  	store: 'GroupLoanRunAwayReceivables', 
 
 

		// { name: 'id', type: 'int' },
		// { name: 'group_loan_id', type: 'int' },
		// { name: 'group_loan_name', type: 'string' },
		// 
		//   	{ name: 'member_id', type: 'int' },
		// { name: 'member_name', type: 'string' },
		// 
		// { name: 'group_loan_weekly_collection_id', type: 'int' },
		// { name: 'group_loan_weekly_collection_week_number', type: 'int' },  
		// { name: 'group_loan_membership_id', type: 'int'},
		// 
		// { name: 'payment_case', type: 'int' },  
		// { name: 'payment_case_text', type: 'string' },
		
		
	initComponent: function() {
		this.columns = [
		
			{
				xtype : 'templatecolumn',
				text : "Group Loan",
				flex : 1,
				tpl : '<b>{group_loan_name}</b>'  
			},
			
			{
				xtype : 'templatecolumn',
				text : "Minggu Kabur",
				flex : 2,
				tpl : '{group_loan_weekly_collection_week_number}'
			},
			{
				xtype : 'templatecolumn',
				text : "Metode Tanggung Renteng",
				flex : 2,
				tpl : '{payment_case_text}'
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
		
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});



		this.tbar = [  this.editObjectButton  ];
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
		// this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		// this.deleteObjectButton.disable();
	}
});
