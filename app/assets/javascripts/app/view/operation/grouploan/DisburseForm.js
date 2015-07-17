Ext.define('AM.view.operation.grouploan.DisburseForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.disbursegrouploanform',

  title : 'Disburse GroupLoan',
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
					fieldLabel: 'Jumlah Penerima Pencarian',
					name: 'disbursed_group_loan_memberships_count' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Dana dicairkan',
					name: 'disbursed_fund' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Dana tidak tercairkan',
					name: 'non_disbursed_fund' 
				},
				{
					xtype: 'datefield',
					name : 'disbursed_at',
					fieldLabel: 'Tanggal Pencairan',
					format: 'Y-m-d',
				}
		 
			]
    }];

    this.buttons = [{
      text: 'Disburse',
      action: 'disburse'
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
		this.down('form').getForm().findField('disbursed_group_loan_memberships_count').setValue(record.get('disbursed_group_loan_memberships_count')); 
		this.down('form').getForm().findField('disbursed_fund').setValue(record.get('disbursed_fund')); 
		this.down('form').getForm().findField('non_disbursed_fund').setValue(record.get('non_disbursed_fund')); 
		this.down('form').getForm().findField('disbursed_at').setValue(record.get('disbursed_at')); 
	}
});
