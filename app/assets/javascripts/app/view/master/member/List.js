Ext.define('AM.view.master.member.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.memberlist',

  	store: 'Members', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'ID_NUMBER', dataIndex: 'id_number'},
			// { header: 'Nama',  dataIndex: 'name', flex: 1},
			
			{
				xtype : 'templatecolumn',
				text : "Details",
				sortable : false,
				flex : 1,
				tpl : '<b>Nama</b>: <br />{name}' + '<br /><br />' + 
							'<b>KTP</b>: <br />{id_card_number}' + '<br /><br />' + 
							'<b>Ultah</b>: <br />{birthday_date}'  
			},
			
			
			{	header: 'Address', dataIndex: 'address', flex: 1 }, 
			
			{
				xtype : 'templatecolumn',
				text : "Status",
				sortable : false,
				flex : 1,
				tpl : '<b>Kabur</b>: <br />{is_run_away}' + '<br /><br />' + 
							'<b>Meninggal</b>: <br />{is_deceased}' + '<br /><br />' + 
							'<b>Ultah</b>: <br />{birthday_date}'  
			},
			
			
			{
				xtype : 'templatecolumn',
				text : "Tabungan",
				sortable : false,
				flex : 1,
				tpl : '<b>Latihan</b>: <br />{total_locked_savings_account}' + '<br /><br />' + 
							'<b>Keanggotaan</b>: <br />{total_membership_savings}' + '<br /><br />' + 
							'<b>Masa Depan</b>: <br />{total_savings_account}'  
			},
			
			{
				xtype : 'templatecolumn',
				text : "Address",
				sortable : false,
				flex : 1,
				tpl : '<b>RT</b>: <br />{rt}' + '<br /><br />' + 
							'<b>RW</b>: <br />{rw}' + '<br /><br />' + 
							'<b>Kelurahan</b>: <br />{village}'  
			},
			
			
			{	header: 'Complete?', dataIndex: 'is_data_complete', flex: 1 }  , 
			
			{	header: 'Active Group Loan', dataIndex: 'active_group_loan_name', flex: 1 }  , 
			
			
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
		
		this.markAsDeceasedObjectButton = new Ext.Button({
			text: 'Deceased',
			action: 'markasdeceasedObject',
			disabled: true
		});

		this.unmarkAsDeceasedObjectButton = new Ext.Button({
			text: 'Cancel Deceased',
			action: 'unmarkasdeceasedObject',
			disabled: true,
			hidden :true 
		});
		
		this.markAsRunAwayObjectButton = new Ext.Button({
			text: 'Run Away',
			action: 'markasrunawayObject',
			disabled: true
		});



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton ,
		 				'-',
						this.searchField,
						'->',
						this.markAsDeceasedObjectButton,
						this.unmarkAsDeceasedObjectButton,
						this.markAsRunAwayObjectButton
						
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
		
		
		this.markAsRunAwayObjectButton.enable();

		this.unmarkAsDeceasedObjectButton.enable();
		this.markAsDeceasedObjectButton.enable();



		selectedObject = this.getSelectedObject();

		if( selectedObject && selectedObject.get("is_deceased") == true ){
			this.unmarkAsDeceasedObjectButton.show();
			this.markAsDeceasedObjectButton.hide();
		}else{
			this.unmarkAsDeceasedObjectButton.hide();
			this.markAsDeceasedObjectButton.show();
		}


	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
		this.markAsDeceasedObjectButton.disable();
		this.unmarkAsDeceasedObjectButton.disable();
		this.markAsRunAwayObjectButton.disable();

		selectedObject = this.getSelectedObject();

		if( selectedObject && selectedObject.get("is_deceased") == true ){
			this.unmarkAsDeceasedObjectButton.show();
			this.markAsDeceasedObjectButton.hide();
		}else{
			this.unmarkAsDeceasedObjectButton.hide();
			this.markAsDeceasedObjectButton.show();
		}
	}
});
