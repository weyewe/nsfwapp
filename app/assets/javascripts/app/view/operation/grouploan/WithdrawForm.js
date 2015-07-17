Ext.define('AM.view.operation.grouploan.WithdrawForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.withdrawgrouploanform',

  title : 'Withdraw Compulsory Savings',
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
					name: 'name' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Jumlah Tabungan Wajib',
					name: 'compulsory_savings_return_amount' 
				}, 
				{
					xtype: 'datefield',
					name : 'compulsory_savings_withdrawn_at',
					fieldLabel: 'Tanggal Pengembalian Tabungan Wajib',
					format: 'Y-m-d',
				}
		 
			]
    }];

    this.buttons = [{
      text: 'Confirm',
      action: 'confirmWithdraw'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	setParentData: function( record ) {
		this.down('form').getForm().findField('name').setValue(record.get('name')); 
		this.down('form').getForm().findField('compulsory_savings_return_amount').setValue(record.get('compulsory_savings_return_amount')); 
		this.down('form').getForm().findField('compulsory_savings_withdrawn_at').setValue(record.get('compulsory_savings_withdrawn_at')); 
	}
});
