Ext.define('AM.view.operation.grouploanweeklycollection.attendance.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.grouploanweeklycollectionattendanceform',

  title : 'Add / Edit Attendance Entry',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
 
	remoteJsonStore : null,
	
  initComponent: function() {

		
    this.items = [{
      xtype: 'form',
	msgTarget	: 'side',
	border: false,
      bodyPadding: 10,
			fieldDefaults: {
          labelWidth: 165,
					anchor: '100%'
      },
      items: [
			{
		        xtype: 'hidden',
		        name : 'id',
		        fieldLabel: 'id'
		    },
		    {
		        xtype: 'hidden',
		        name : 'group_loan_weekly_collection_id',
		        fieldLabel: 'group_loan_weekly_collection_id'
		    },
		    {
		        xtype: 'hidden',
		        name : 'group_loan_membership_id',
		        fieldLabel: 'group_loan_membership_id'
		    },
		    {
				xtype: 'displayfield',
				name : 'member_name',
				fieldLabel: 'Member'
			},
			{
				xtype: 'displayfield',
				name : 'group_loan_weekly_collection_week_number',
				fieldLabel: 'Pengumpulan'
			},
			{
				fieldLabel : 'Tepat Waktu',
				name : 'attendance_status',
				xtype : 'checkbox'
			},
			{
				fieldLabel : 'Bayar',
				name : 'payment_status',
				xtype : 'checkbox'
			}
		]
    }];

    this.buttons = [{
      text: 'Save',
      action: 'save'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

  setParentData: function( record ){
		this.down('form').getForm().findField('member_name').setValue(record.get('id')); 
	},
	setSelfData: function(record){
		this.down('form').getForm().findField('member_name').setValue( record.get('member_name'));
	}

});

