Ext.define('AM.view.operation.grouploan.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploanlist',

  	store: 'GroupLoans', 
 

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
			{ header: 'Group No', dataIndex: 'group_number'   },
			{
				xtype : 'templatecolumn',
				text : "Info",
				flex : 1,
				tpl : '<b>{name}</b>' + '<br />' + '<br />' + 
							'Jumlah Meeting: <br /><b>{number_of_meetings}</b>'  + '<br />' + '<br />' + 
							'Jumlah Pengumpulan: <br /><b>{number_of_collections}</b>'  + '<br />' + '<br />' + 
							'Anggota Aktif: <br /><b>{active_group_loan_memberships_count}</b>'
			},
			{
				xtype : 'templatecolumn',
				text : "Start",
				flex : 1,
				tpl : 'Status: <b>{is_started}</b>'+ '<br />' + '<br />' + 
							'Dana harus disiapkan: <br /><b>{ start_fund}</b>' + '<br />' + '<br />' + 
							'Anggota Terdaftar: <br /><b>{total_members_count}</b>' + '<br />' + '<br />' + 
							'Tanggal Mulai: <br /><b>{started_at}</b>' 
			},
			
			{
				xtype : 'templatecolumn',
				text : "Disbursement",
				flex : 1,
				tpl : 'Status: <b>{is_loan_disbursed}</b>' + '<br />' + '<br />' +  
							'Dana Dicairkan: <br /><b>{disbursed_fund}</b>'+ '<br />' + '<br />' + 
							'Dana Tak Tercairkan: <br /><b>{non_disbursed_fund}</b>'+ '<br />' + '<br />' + 
							'Anggota Penerima: <br /><b>{disbursed_group_loan_memberships_count}</b>'+ '<br />' + '<br />' +  
							'Tanggal Mulai: <br /><b>{disbursed_at}</b>'     
			},
			
			{
				xtype : 'templatecolumn',
				text : "Selesai",
				flex : 1,
				tpl : 'Status: <b>{is_closed}</b>' + '<br />' + '<br />' +
							'Total Tabungan wajib sebelum penutupan: <br /><b>{total_compulsory_savings_pre_closure}</b>' + '<br />' + '<br />' +
							'Titipan premature clearance: <br /><b>{premature_clearance_deposit}</b>' + '<br />' + '<hr />' +  
							
							
							'Pendapatan bagi hasil dari member kabur, penyelesaian di akhir: <br /><b>{expected_revenue_from_run_away_member_end_of_cycle_resolution}</b>' + '<br />' + '<br />' + 
							
							'Bad Debt Allowance: <br /><b>{bad_debt_allowance}</b>' + '<br />' + '<br />' + 
							'Bad Debt Expense:  <br /><b>{bad_debt_expense}</b>' + '<br />' + '<br />' + 
							'Tanggal Selesai: <br /><b>{closed_at}</b>'     
			},
			
			{
				xtype : 'templatecolumn',
				text : "Savings Return",
				flex : 1,
				tpl : 'Status: <b>{is_compulsory_savings_withdrawn}</b>' + '<br />' + '<br />' + 
							'Pengembalian: <br /><b>{compulsory_savings_return_amount}</b>' + '<br />' + '<br />' +
							'TanggalPengembalian: <br /><b>{compulsory_savings_withdrawn_at}</b>'     
			},
			
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
		
		this.startObjectButton = new Ext.Button({
			text: 'Start',
			action: 'startObject',
			disabled: true
		});
		
		this.unstartObjectButton = new Ext.Button({
			text: 'Cancel Start',
			action: 'unstartObject',
			disabled: true,
			hidden : true 
		});
		
		this.disburseObjectButton = new Ext.Button({
			text: 'Disburse',
			action: 'disburseObject',
			disabled: true
		});
		
		this.undisburseObjectButton = new Ext.Button({
			text: 'Cancel Disburse',
			action: 'undisburseObject',
			disabled: true,
			hidden : true 
		});
		
		this.closeObjectButton = new Ext.Button({
			text: 'Close',
			action: 'closeObject',
			disabled: true
		});
		this.withdrawObjectButton = new Ext.Button({
			text: 'Withdraw',
			action: 'withdrawObject',
			disabled: true
		});
		
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});
		
		this.downloadPendingButton = new Ext.Button({
			text: 'FKS',
			action: 'downloadPending',
			disabled: false
		});
		



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton,
		  			'-',
						this.startObjectButton, this.unstartObjectButton,
						this.disburseObjectButton,this.undisburseObjectButton,
						this.closeObjectButton,
						this.withdrawObjectButton, 
						'-',
						this.searchField,
						'->',
						// this.downloadPendingButton
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
		this.startObjectButton.enable();
		this.unstartObjectButton.enable();
		this.disburseObjectButton.enable();
		this.undisburseObjectButton.enable();
		this.closeObjectButton.enable();
		this.withdrawObjectButton.enable();
		// this.downloadPendingButton.enable();
		
		selectedObject = this.getSelectedObject();
		if( selectedObject && selectedObject.get("is_started") == true ){
			this.startObjectButton.hide();
			this.unstartObjectButton.show();
		}else{
			this.startObjectButton.show();
			this.unstartObjectButton.hide();
		}
		
		if( selectedObject && selectedObject.get("is_loan_disbursed") == true ){
			this.disburseObjectButton.hide();
			this.undisburseObjectButton.show();
		}else{
			this.disburseObjectButton.show();
			this.undisburseObjectButton.hide();
		}
		
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
		this.startObjectButton.disable();
		this.disburseObjectButton.disable();
		this.closeObjectButton.disable();
		this.withdrawObjectButton.disable();
		// this.downloadPendingButton.disable();
	}
});
