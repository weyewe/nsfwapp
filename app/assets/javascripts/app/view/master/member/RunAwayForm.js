Ext.define('AM.view.master.member.RunAwayForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.markmemberasrunawayform',

  title : 'Confirm Member Run Away',
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
					xtype: 'datefield',
					name : 'run_away_at',
					fieldLabel: 'Tanggal Konfirmasi Kabur',
					format: 'Y-m-d',
				}
		 
			]
    }];

    this.buttons = [{
      text: 'Confirm',
      action: 'confirmRunAway'
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
