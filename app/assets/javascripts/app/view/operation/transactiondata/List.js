Ext.define('AM.view.operation.transactiondata.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.transactiondatalist',

  	store: 'TransactionDatas',  
 

	initComponent: function() {
		this.columns = [
			// { header: 'ID', dataIndex: 'id'},
			{ header: 'ID',  dataIndex: 'id', flex: 1},
			{ header: 'Tangal Transaksi',  dataIndex: 'transaction_datetime', flex: 2},
			
			
			
 
			{
				xtype : 'templatecolumn',
				text : "Detail",
				flex : 4,
				tpl : '<b>{transaction_source_type}</b>' + '<br />' + '<br />' +
							'{description}'  + '<br />' + '<br />' +
							'Kode: <b>{code}</b>' 
			},
			
			
		];


		this.setPeriodObjectButton = new Ext.Button({
			text: 'Set Period',
			action: 'setPeriodObject'
		});
		
		this.downloadObjectButton = new Ext.Button({
			text: 'Download',
			action: 'downloadObject',
			disabled : false 
		});
		
		
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
		
		this.tbar = [this.setPeriodObjectButton,  this.downloadObjectButton ]; 
		
	 
			


		
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: 'Displaying transactions {0} - {1} of {2}',
			emptyMsg: "No transactions" 
		});

		this.callParent(arguments);
	},
 
	loadMask	: true,
	
	getSelectedObject: function() {
		return this.getSelectionModel().getSelection()[0];
	},
	
	enableDownloadButton: function(){
		this.downloadObjectButton.enable();
	},

	enableRecordButtons: function() {
		// this.editObjectButton.enable();
		// this.deleteObjectButton.enable(); 
		// 
		// selectedObject = this.getSelectedObject();
		// 
		// if( selectedObject && selectedObject.get("is_confirmed") == true ){
		// 	this.confirmObjectButton.hide();
		// 	this.unconfirmObjectButton.show();
		// 	this.unconfirmObjectButton.enable();
		// }else{
		// 	this.confirmObjectButton.enable();
		// 	this.confirmObjectButton.show();
		// 	this.unconfirmObjectButton.hide();
		// }
	},

	disableRecordButtons: function() {
		// this.editObjectButton.disable();
		// this.deleteObjectButton.disable();
		// this.confirmObjectButton.disable(); 
	}
});
