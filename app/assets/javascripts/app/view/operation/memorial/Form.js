
Ext.define('AM.view.operation.memorial.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.memorialform',

  title : 'Add / Edit Memorial',
  layout: 'fit',
	width	: 500,
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
	        xtype: 'hidden',
	        name : 'id',
	        fieldLabel: 'id'
	      },{
		        xtype: 'displayfield',
		        name : 'code',
		        fieldLabel: 'Kode'
		    },{
					xtype: 'datefield',
					name : 'transaction_datetime',
					fieldLabel: 'Tanggal Transaksi',
					format: 'Y-m-d',
				},{
	        xtype: 'textarea',
	        name : 'description',
	        fieldLabel: 'Deskripsi'
	      },
			
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
 
});




