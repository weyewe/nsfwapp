Ext.define('AM.view.operation.loantrail.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.loantraillist',

  	store: 'LoanTrails', 
 

		// { name: 'id', type: 'int' },
		//   	{ name: 'number_of_meetings', type: 'int' },
		// { name: 'number_of_collections', type: 'int' } ,
		// { name: 'is_started', type: 'boolean' }   ,
		// { name: 'is_loan_disbursed', type: 'boolean' }   ,
		// { name: 'is_closed', type: 'boolean' }   ,
		// { name: 'is_compulsory_savings_withdrawn', type: 'boolean' }
		// 

	initComponent: function() {
		this.columns = [
			// { header: 'Member', dataIndex: 'member_name' , flex : 1 },
			{
				xtype : 'templatecolumn',
				text : "Member",
				flex : 1,
				tpl : '<b>{member_id_number}</b>' + '<br />' + 
							'Nama: <b>{member_name}</b>' + '<br />' + 
							'Alamat: {member_address}'  
			},
			
			{
				xtype : 'templatecolumn',
				text : "Produk",
				flex : 1,
				tpl : '<b>{group_loan_product_name}</b>' + '<br />' + 
							'Durasi: <b>{group_loan_product_total_weeks}</b>' + '<br />' + 
							'Pokok: <b>{group_loan_product_principal}</b>' + '<br />' + 
							'Bunga: <b>{group_loan_product_interest}</b>' + '<br />' + 
							'Tabungan Wajib: <b>{group_loan_product_compulsory_savings}</b>' + '<br />' + 
							'Admin fee: <b>{group_loan_product_admin_fee}</b>' 
			},
			
			
			{
				xtype : 'templatecolumn',
				text : "Group Loan",
				flex : 1,
				tpl : 'Is Active?<br /><b>{is_active}</b>' + '<br />' + 
							'<b>{deactivation_case_name}</b>' + '<br />' + 
							'Name: <b>{group_loan_name}</b>' + '<br />' + 
							'No: <b>{group_loan_group_number}</b>' + '<br />' + 
							'Disbursement Date: <br /><b>{group_loan_disbursed_at}</b>'  
			},
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
		// return this.getSelectionModel().getSelection()[0];
	},
	
	enableAddButton: function(){
		// this.addObjectButton.enable();
	},
	disableAddButton : function(){
		// this.addObjectButton.disable();
	},

	enableRecordButtons: function() {
		// this.editObjectButton.enable();
		// this.deleteObjectButton.enable();
		// this.deactivateObjectButton.enable();
		
	},

	disableRecordButtons: function() {
		// this.editObjectButton.disable();
		// this.deleteObjectButton.disable();
		// this.deactivateObjectButton.disable();
	}
});
