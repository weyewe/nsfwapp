Ext.define('AM.view.operation.memorial.StartForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.confirmmemorialform',

  title : 'Confirm Memorial',
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
					fieldLabel: 'Kode',
					name: 'code' 
				},
			 
				{
					xtype: 'displayfield',
					fieldLabel: 'Tanggal Transaksi',
					name: 'transaction_datetime' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Deskripsi',
					name: 'description' 
				},
				{
					xtype: 'datefield',
					fieldLabel: 'Tanggal Konfirmasi',
					name: 'confirmed_at' ,
					format: 'Y-m-d',
				},  
		 
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
		this.down('form').getForm().findField('code').setValue(record.get('code')); 
		this.down('form').getForm().findField('transaction_datetime').setValue(record.get('transaction_datetime')); 
		this.down('form').getForm().findField('description').setValue(record.get('description')); 
	}
});
