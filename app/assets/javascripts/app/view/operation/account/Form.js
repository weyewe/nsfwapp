Ext.define('AM.view.operation.account.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.accountform',

  title : 'Add / Edit Account',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
	// 
	// self.create_object({
	//     :name => "Cash Drawer",
	//     :parent_id => cash_account.id , 
	//     :account_case => ACCOUNT_CASE[:ledger],
	//     :is_contra_account => false,
	//     :original_account_id => nil,
	//     :code  => APP_SPECIFIC_ACCOUNT_CODE[:cash_drawer]
	//   },true
	//     
	//   )
	// 

  initComponent: function() {
	
		
		
		var localJsonStoreAccountCase = Ext.create(Ext.data.Store, {
			type : 'array',
			storeId : 'account_case_search',
			fields	: [ 
				{ name : "account_case"}, 
				{ name : "account_case_text"}  
			], 
			data : [
				{ account_case : 1, account_case_text : "Group"},
				{ account_case : 2, account_case_text : "Ledger"}
			] 
		});
		
		var remoteJsonStoreAccount = Ext.create(Ext.data.JsonStore, {
			storeId : 'ledger_account_search',
			fields	: [
			 				{
						name : 'account_name',
						mapping : "name"
					}, 
					{
						name : 'account_id',
						mapping : 'id'
					}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_ledger_accounts',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			},
			autoLoad : false 
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
	        name : 'parent_id',
	        fieldLabel: 'id'
	      },
				{
					// Fieldset in Column 2 - collapsible via checkbox, collapsed by default, contains a panel
					xtype:'fieldset',
					title: 'Account Info', // title or checkboxToggle creates fieldset header  
					layout:'anchor',
					items :[ 
						{
							xtype: 'displayfield',
							fieldLabel: 'Parent Account',
							name: 'parent_name',
							value: '10'
						},
						{
			        xtype: 'textfield',
			        name : 'name',
			        fieldLabel: 'Nama Account'
						},
						{
			        xtype: 'textfield',
			        name : 'code',
			        fieldLabel: 'Kode Account'
						},
						{
							fieldLabel: 'Account Case',
							xtype: 'combo',
							queryMode: 'remote',
							forceSelection: true, 
							displayField : 'account_case_text',
							valueField : 'account_case',
							pageSize : 5,
							minChars : 1, 
							allowBlank : false, 
							triggerAction: 'all',
							store : localJsonStoreAccountCase , 
							listConfig : {
								getInnerTpl: function(){
									return  	'<div data-qtip="{account_case_text}">' +  
															'<div class="combo-name">{account_case_text}</div>' +  
									 					'</div>';
								}
							},
							name : 'account_case' 
						},
					]
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
  } ,


	setParentData: function( record ){
		this.down('form').getForm().findField('parent_name').setValue(record.get('name')); 
		this.down('form').getForm().findField('parent_id').setValue(record.get('id')); 
	},
	
 
	setSelectedOriginalAccountId: function( original_account_id ){
		// console.log("inside set selected original account id ");
		// var comboBox = this.down('form').getForm().findField('original_account_id'); 
		// var me = this; 
		// var store = comboBox.store; 
		// store.load({
		// 	params: {
		// 		selected_id : original_account_id 
		// 	},
		// 	callback : function(records, options, success){
		// 		me.setLoading(false);
		// 		comboBox.setValue( original_account_id );
		// 	}
		// });
	},
	
	
	
	setComboBoxData : function( record){
		// var me = this; 
		// me.setLoading(true);
		
		
		// me.setSelectedOriginalAccountId( record.get("original_account_id")  ) ; 
	}
});
