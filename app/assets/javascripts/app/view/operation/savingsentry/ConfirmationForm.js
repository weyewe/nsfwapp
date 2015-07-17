Ext.define('AM.view.operation.savingsentry.ConfirmationForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.confirmsavingsentryform',

  title : 'Confirm SavingsEntry',
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
					fieldLabel: 'Member',
					name: 'member_name' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'ID',
					name: 'member_id_number' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Jumlah Tabungan',
					name: 'amount' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Tipe Transaksi',
					name: 'direction_text' 
				},
				{
					xtype: 'datefield',
					name : 'confirmed_at',
					fieldLabel: 'Tanggal Transaksi',
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
		this.down('form').getForm().findField('member_name').setValue(record.get('member_name')); 
		this.down('form').getForm().findField('member_id_number').setValue(record.get('member_id_number')); 
		this.down('form').getForm().findField('amount').setValue(record.get('amount')); 
		this.down('form').getForm().findField('direction_text').setValue(record.get('direction_text')); 
	}
});
