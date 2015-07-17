Ext.define('AM.view.operation.MemberList' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.operationmemberList',

  	store: 'Members', 
   
	showTotalSavingsAmount: false, 
	showTotalLockedSavingsAmount: false,
	showTotalMembershipSavingsAmount: false,

	initComponent: function() {
		
		var templateBuilder = '<b>{name}</b>' + '<br />' + 
					'ID : <b>{id_number}</b>' + '<br />'  + 
					'Alamat: <b>{address}</b>' ; 
					
		if( this.showTotalSavingsAmount === true ){
			templateBuilder += '<br />'  + 
												'Total Savings: <b>{total_savings_account}</b>' ;
		}
		
		if( this.showTotalLockedSavingsAmount === true ){
			templateBuilder += '<br />'  + 
												'Locked Savings: <b>{total_locked_savings_account}</b>' ;
		}
		
		if( this.showTotalMembershipSavingsAmount === true ){
			templateBuilder += '<br />'  + 
												'Membership Savings: <b>{total_membership_savings}</b>' ;
		}
					
		this.columns = [
		
			{
				xtype : 'templatecolumn',
				text : "Member",
				flex : 1,
				// tpl : '<b>{name}</b>' + '<br />' + 
				// 			'ID : <b>{id_number}</b>' + '<br />'  + 
				// 			'Alamat: <b>{address}</b>'
				
				tpl: templateBuilder
			}, 
		];

	 
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});



		this.tbar = [this.searchField ];
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
