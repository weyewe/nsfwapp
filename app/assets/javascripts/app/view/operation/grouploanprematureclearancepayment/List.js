Ext.define('AM.view.operation.grouploanprematureclearancepayment.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploanprematureclearancepaymentlist',
  	store: 'GroupLoanPrematureClearancePayments', 
 
 
	initComponent: function() {
		this.columns = [
		
			{
				xtype : 'templatecolumn',
				text : "Info",
				flex : 1,
				tpl : '<b>{group_loan_membership_member_name}</b>' + '<br />' + 
							'Id: {group_loan_membership_member_id_number}' + '<br />' + 
							'Alamat: {group_loan_membership_member_address}'  + '<br />' + '<br />' + 
							'Minggu Pengajuan: {group_loan_weekly_collection_week_number}'  + '<br />' + 
							'Status Konfirmasi: <b>{is_confirmed}</b>'
			},
			{
				xtype : 'templatecolumn',
				text : "Jumlah",
				flex : 2,
				tpl : 'Pengembalian Pokok: {total_principal_return}' + '<br />'  +  
							'Titipan Kabur bayar mingguan: {run_away_weekly_resolution_bail_out}' + '<br />'  +  
							'Titipan Kabur bayar di akhir: {run_away_end_of_cycle_resolution_bail_out}' + '<br />'  +  '<br />' +
							'( Tabungan Wajib : {available_compulsory_savings} )' + '<br />'  +  '<br />' + 
							'Total : <b>{amount}</b>' + '<br />'  +  '<br />' + 
							
							'Pengembalian Sisa Tabungan Wajib: {remaining_compulsory_savings}'
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
		
		this.confirmObjectButton = new Ext.Button({
			text: 'Confirm',
			action: 'confirmObject',
			disabled: true
		});
		
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton ];
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
