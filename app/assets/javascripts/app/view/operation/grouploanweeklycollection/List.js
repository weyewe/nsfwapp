Ext.define('AM.view.operation.grouploanweeklycollection.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploanweeklycollectionlist',

  	store: 'GroupLoanWeeklyCollections', 
 
 
	initComponent: function() {
		this.columns = [
			{ header: 'Week', dataIndex: 'week_number' , sortable : false }, 
			
		 
			{
				xtype : 'templatecolumn',
				text : "Pengumpulan",
				sortable : false,
				flex : 1,
				tpl : '<b>{is_collected}</b>'   + '<br /><br />' + 
							'Waktu Pengumpulan: <br />{collected_at}'
			},
			{
				xtype : 'templatecolumn',
				text : "Konfirmasi",
				sortable : false,
				flex : 1,
				tpl : '<b>{is_confirmed}</b>'   + '<br /><br />' + 
							'Waktu Konfirmasi: <br />{confirmed_at}'
			},
			
			{
				xtype : 'templatecolumn',
				text : "Kasus khusus",
				sortable : false,
				flex : 1,
				tpl : 'Tak Tertagih: <b>{group_loan_weekly_uncollectible_count}</b>' + '<br />' + 
							'Meninggal: <b>{group_loan_deceased_clearance_count}</b>' + '<br />' + 
							'Kabur: <b>{group_loan_run_away_receivable_count}</b>' + '<br />' + 
							'Premature Clearance: <b>{group_loan_premature_clearance_payment_count}</b>' 
			},
			
			{
				xtype : 'templatecolumn',
				text : "Jumlah Penerimaan",
				sortable : false,
				flex : 1,
				tpl : '<b>{amount_receivable}</b>'   
			},
			
			
		];

		this.collectObjectButton = new Ext.Button({
			text: 'Collect',
			action: 'collectObject',
			disabled: true
		});
		this.uncollectObjectButton = new Ext.Button({
			text: 'Uncollect',
			action: 'uncollectObject',
			disabled: true,
			hidden :true 
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
 


 		this.downloadFormObjectButton = new Ext.Button({
			text: 'LKS',
			action: 'downloadFormObject',
			disabled: true
		});


		this.tbar = [ this.collectObjectButton, this.uncollectObjectButton, '-',
								this.confirmObjectButton , 	this.unconfirmObjectButton,
								'->',  this.downloadFormObjectButton];
								
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
		this.collectObjectButton.enable();
		this.confirmObjectButton.enable();
		this.unconfirmObjectButton.enable();
		this.uncollectObjectButton.enable();

		this.downloadFormObjectButton.enable();
		
		selectedObject = this.getSelectedObject();
		if( selectedObject && selectedObject.get("is_collected") == true ){
			this.collectObjectButton.hide();
			this.uncollectObjectButton.show();
		}else{
			this.collectObjectButton.show();
			this.uncollectObjectButton.hide();
		}
		
		if( selectedObject && selectedObject.get("is_confirmed") == true ){
			this.confirmObjectButton.hide();
			this.unconfirmObjectButton.show();
		}else{
			this.confirmObjectButton.show();
			this.unconfirmObjectButton.hide();
		}
		
	},

	disableRecordButtons: function() {
		this.collectObjectButton.disable();
		this.confirmObjectButton.disable();
		this.unconfirmObjectButton.disable();
		this.uncollectObjectButton.disable();
		this.downloadFormObjectButton.disable();
	}
});
