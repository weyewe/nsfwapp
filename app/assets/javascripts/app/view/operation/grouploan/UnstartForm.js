Ext.define('AM.view.operation.grouploan.UnstartForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.unstartgrouploanform',

  title : 'Cancel start GroupLoan',
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
					fieldLabel: 'Jumlah Anggota',
					name: 'total_members_count' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Jumlah Meeting',
					name: 'number_of_meetings' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Jumlah Pengumpulan',
					name: 'number_of_collections' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Dana harus disiapkan',
					name: 'start_fund' 
				} 
		 
			]
    }];

    this.buttons = [{
      text: 'Cancel Start',
      action: 'unstart'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	setParentData: function( record ) {
		// console.log("Inside set Parent Data");
// d.get('total_members_count') );
		this.down('form').getForm().findField('name').setValue(record.get('name')); 
		this.down('form').getForm().findField('total_members_count').setValue(record.get('total_members_count')); 
		this.down('form').getForm().findField('number_of_meetings').setValue(record.get('number_of_meetings')); 
		this.down('form').getForm().findField('number_of_collections').setValue(record.get('number_of_collections')); 
		this.down('form').getForm().findField('start_fund').setValue(record.get('start_fund')); 
	}
});
