Ext.define('AM.view.operation.grouploanweeklyuncollectible.CollectForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.collectgrouploanweeklyuncollectibleform',

  title : 'Collect GroupLoanWeeklyUncollectible',
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
					name: 'group_loan_name' 
				},
			 
				{
					xtype: 'displayfield',
					fieldLabel: 'Week',
					name: 'week_number' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Jumlah Penerimaan',
					name: 'amount' 
				},
			
				{
					xtype: 'datefield',
					name : 'collected_at',
					fieldLabel: 'Tanggal Penerimaan',
					format: 'Y-m-d',
				}
		 
			]
    }];

    this.buttons = [{
      text: 'Collect',
      action: 'collect'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	setParentData: function( record ) {
		
		console.log("inside setParentData");
		
		this.down('form').getForm().findField('group_loan_name').setValue(record.get('group_loan_name')); 
		this.down('form').getForm().findField('week_number').setValue(record.get('group_loan_weekly_collection_week_number')); 
		this.down('form').getForm().findField('amount').setValue(record.get('amount')); 
		this.down('form').getForm().findField('collected_at').setValue(record.get('collected_at')); 
	}
});
