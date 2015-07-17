Ext.define('AM.view.operation.grouploan.CloseForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.closegrouploanform',

  title : 'Close GroupLoan',
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
					fieldLabel: 'Bad Debt Allowance',
					name: 'bad_debt_allowance' 
				},
				{
					xtype: 'datefield',
					name : 'closed_at',
					fieldLabel: 'Tanggal Penutupan',
					format: 'Y-m-d',
				}
		 
			]
    }];

    this.buttons = [{
      text: 'Confirm',
      action: 'confirmClose'
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
		this.down('form').getForm().findField('bad_debt_allowance').setValue(record.get('bad_debt_allowance')); 
		this.down('form').getForm().findField('closed_at').setValue(record.get('closed_at')); 
	}
});
