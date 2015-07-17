Ext.define('AM.view.operation.grouploanweeklycollection.attendance.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.grouploanweeklycollectionattendancelist',

  	store: 'GroupLoanWeeklyCollectionAttendances', 
 
 
	initComponent: function() {
		this.columns = [
			
		 
			{ header: 'Member', dataIndex: 'member_name'   },
			{ header: 'Attendance Status', dataIndex: 'attendance_status'   },
			{ header: 'Payment Status', dataIndex: 'payment_status'   },
			
			
			
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
 


		this.tbar = [  this.editObjectButton   ];
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: '{0} - {1} of {2}',
			emptyMsg: "0" 
		});

		this.callParent(arguments);
	},
 
	loadMask	: true,
	
	getSelectedObject: function() {
		return this.getSelectionModel().getSelection()[0];
	},
	
	 

	enableRecordButtons: function() {
		this.editObjectButton.enable(); 
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable(); 
	}
});
