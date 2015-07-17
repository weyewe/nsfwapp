
Ext.define('AM.view.operation.transactiondata.DownloadForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.transactiondatadownloadform',

  title : 'Set your Download Period',
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
					xtype: 'datefield',
					name : 'start_date',
					fieldLabel: 'Tanggal Mulai',
					format: 'Y-m-d',
				},
				{
					xtype: 'datefield',
					name : 'end_date',
					fieldLabel: 'Tanggal Selesai',
					format: 'Y-m-d',
				}, 
				{
					xtype: 'textfield',
					name : 'email',
					fieldLabel: 'Email tujuan report',
					vtype: 'email'
				},
			
			]
    }];

    this.buttons = [{
      text: 'Execute',
      action: 'save'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },
 
});




