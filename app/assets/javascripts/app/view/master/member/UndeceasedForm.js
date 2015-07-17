Ext.define('AM.view.master.member.UndeceasedForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.unmarkmemberasdeceasedform',

  title : 'Confirm Cancel Member Deceased',
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
		 
			]
    }];

    this.buttons = [{
      text: 'Confirm',
      action: 'unconfirmDeceased'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	setParentData: function( record ) {
		this.down('form').getForm().findField('member_name').setValue(record.get('name')); 
		this.down('form').getForm().findField('member_id_number').setValue(record.get('id_number')); 
	}
});
