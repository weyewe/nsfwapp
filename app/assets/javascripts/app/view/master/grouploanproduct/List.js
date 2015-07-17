Ext.define('AM.view.master.grouploanproduct.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploanproductlist',

  	store: 'GroupLoanProducts', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'Nama', dataIndex: 'name'},
			{ header: 'Durasi',  dataIndex: 'total_weeks' },
			
			// {
			// 	xtype : 'templatecolumn',
			// 	text : "Weekly Installment",
			// 	sortable : false,
			// 	flex : 1,
			// 	tpl : '<b>{weekly_payment_amount}</b>' + '<br /><br />' + 
			// 				'<b>Principal</b>: <br />{principal}' + '<br /><br />' + 
			// 				'<b>Interest</b>: <br />{interest}' + '<br /><br />' + 
			// 				'<b>Tabungan Wajib</b>: <br />{compulsory_savings}'  
			// },
			{	header: 'Weekly Installment', dataIndex: 'weekly_payment_amount', flex: 1 } ,
			{	header: 'Pokok Mingguan', dataIndex: 'principal', flex: 1 } ,
			{	header: 'Bunga Mingguan', dataIndex: 'interest', flex: 1 } ,
			{	header: 'Tabungan Wajib Mingguan', dataIndex: 'compulsory_savings', flex: 1 } ,
			{	header: 'Biaya Admin', dataIndex: 'admin_fee', flex: 1 } ,
			
			
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add',
			action: 'addObject'
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



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton ,
				'-',
				this.searchField
		 	];
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

	enableRecordButtons: function() {
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
	}
});
