Ext.define('AM.view.operation.grouploanweeklycollection.ConfirmForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.confirmgrouploanweeklycollectionform',

  title : 'Confirm GroupLoanWeeklyCollection',
  layout: 'fit',
	width	: 400,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
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
					xtype: 'displayfield',
					fieldLabel: 'GroupLoan',
					name: 'group_loan_name' 
				},
			 
				{
					xtype: 'displayfield',
					fieldLabel: 'Week',
					name: 'week_number' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Jumlah Penerimaan',
					name: 'amount_receivable' 
				},
			
				{
					xtype: 'datefield',
					name : 'confirmed_at',
					fieldLabel: 'Tanggal Konfirmasi',
					format: 'Y-m-d',
				}
		 
			]
    }];

    this.buttons = [{
      text: 'Confirm',
      action: 'confirm'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	setParentData: function( record ) {
		this.down('form').getForm().findField('group_loan_name').setValue(record.get('group_loan_name')); 
		this.down('form').getForm().findField('week_number').setValue(record.get('week_number')); 
		this.down('form').getForm().findField('amount_receivable').setValue(record.get('amount_receivable')); 
		this.down('form').getForm().findField('confirmed_at').setValue(record.get('confirmed_at')); 
	}
});
