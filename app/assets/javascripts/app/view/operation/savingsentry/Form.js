Ext.define('AM.view.operation.savingsentry.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.savingsentryform',

  // title : 'Add / Edit Savings Entry',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true,  
	 
 
  initComponent: function() {
		var me = this; 
		
		var localJsonStoreDirection = Ext.create(Ext.data.Store, {
			type : 'array',
			storeId : 'fund_transfer_direction',
			fields	: [ 
				{ name : "direction"}, 
				{ name : "direction_text"}  
			], 
			data : [
				{ direction : 1, direction_text : "Penambahan"},
				{ direction : 2, direction_text : "Penarikan"}
			] 
		});
		 
		 
		
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
	      },
				{
	        xtype: 'hidden',
	        name : 'member_id',
	        fieldLabel: 'GroupLoan ID'
	      },
				{
	        xtype: 'hidden',
	        name : 'savings_status',
	        fieldLabel: 'Savings Status'
	      },
				{
					xtype: 'displayfield',
					fieldLabel: 'Member:',
					name: 'member_name' ,
					value : '10' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'ID Number:',
					name: 'member_id_number' ,
					value : '10' 
				},
				{
					xtype: 'textfield',
					fieldLabel: 'Jumlah:',
					name: 'amount'   
				},
				{
					fieldLabel: 'Tipe Transaksi',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'direction_text',
					valueField : 'direction',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : localJsonStoreDirection, 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{direction_text}">' +  
													'<div class="combo-name">{direction_text}</div>' +
							 					'</div>';
						}
					},
					name : 'direction' 
				}
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
 
	// setComboBoxData : function( record){ 
	// 	var me = this; 
	// 	me.setLoading(true);
	// 	me.setSelectedGroupLoanMembership( record.get("group_loan_membership_id")  ) ;
	// 	me.setSelectedGroupLoanWeeklyCollection( record.get("group_loan_weekly_collection_id")  ) ;
	// },
	
	setParentData: function( record ){ 
		this.down('form').getForm().findField('member_name').setValue(record.get('name')); 
		this.down('form').getForm().findField('member_id_number').setValue(record.get('id_number')); 
		this.down('form').getForm().findField('member_id').setValue(record.get('id')); 
	},
	
	setSavingsStatus: function( savingsStatus ){
		this.down('form').getForm().findField('savings_status').setValue( savingsStatus ); 
	},
	
	setConditionalTitle: function(savingsStatus){
		// console.log("SetConditionalTitle is called");
		if( savingsStatus == 0 ){
			this.setTitle( "Voluntary Savings");
		}else if( savingsStatus == 1 ){
			this.setTitle("Membership Savings");
		}else if( savingsStatus == 2 ) {
			this.setTitle("Locked Savings");
		}
	}
});

