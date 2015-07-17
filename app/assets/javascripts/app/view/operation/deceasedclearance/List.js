Ext.define('AM.view.operation.deceasedclearance.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.deceasedclearancelist',
  	store: 'DeceasedClearances', 
 
 
	initComponent: function() {
		this.columns = [
		
			{
				xtype : 'templatecolumn',
				text : "Produk",
				flex : 1,
				tpl : '<b>{financial_product_name}</b>' + '<br />' + '<br />' + 
							'Jenis Produk: <b>{financial_product_type}</b>'  + '<br />' + '<br />' + 
							'Sisa Pokok: <b>{principal_return}</b>'  + '<br />' + '<br />' + 
							'Donasi: <b>{donation}</b>'   + '<br />' + '<br />' + 
							'Migrasi Tabungan: <b>{additional_savings_account}</b>'
			},
			{
				xtype : 'templatecolumn',
				text : "Penyelesaian",
				flex : 2,
				tpl : 'Ditanggung Asuransi: <b>{is_insurance_claimable}</b>' + '<br />'  + '<br />'  + 
							'Konfirmasi: <b>{is_confirmed}</b>' +  '<br />'  + '<br />'   
			},
			{
				xtype : 'templatecolumn',
				text : "Progress",
				flex : 2,
				tpl : 'Claim di submit: <b>{is_insurance_claim_submitted}</b>' + '<br />'  + '<br />'  +  
							'Submisi Claim di Approve: <b>{is_insurance_claim_submitted}</b>' + '<br />'  + '<br />'  +  
							'Uang claim di terima: <b>{is_claim_received}</b>' + '<br />'  + '<br />'  +  
							'Donasi diberikan: <b>{is_donation_disbursed}</b>'  
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



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton  ];
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
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
	}
});
