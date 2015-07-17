
Ext.define('AM.view.operation.memorialdetail.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.memorialdetailform',

  title : 'Add / Edit Memorial Detail',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	
		var localJsonStoreEntryCase = Ext.create(Ext.data.Store, {
			type : 'array',
			storeId : 'entry_case_search',
			fields	: [ 
				{ name : "entry_case"}, 
				{ name : "entry_case_text"}  
			], 
			data : [
				{ entry_case : 1, entry_case_text : "Debit"},
				{ entry_case : 2, entry_case_text : "Credit"}
			] 
		});
		
		var remoteJsonStoreAccount = Ext.create(Ext.data.JsonStore, {
			storeId : 'memorial_detail_account_search',
			fields	: [
			 		{
						name : 'account_name',
						mapping : "name"
					}, 
					{
						name : 'account_id',
						mapping : 'id'
					},
					{
						name : 'account_account_case',
						mapping : "account_case"
					}, 
					{
						name : 'account_account_case_text',
						mapping : 'account_case_text'
					},
					{
						name : 'account_code',
						mapping : 'code'
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
	        name : 'memorial_id',
	        fieldLabel: 'memorial_id'
	      },{
		      xtype: 'displayfield',
	        name : 'memorial_code',
	        fieldLabel: 'Kode Memorial'
		    },
				{
					fieldLabel: 'Entry Case',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'entry_case_text',
					valueField : 'entry_case',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : localJsonStoreEntryCase , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{entry_case_text}">' +  
													'<div class="combo-name">{entry_case_text}</div>' +  
							 					'</div>';
						}
					},
					name : 'entry_case' 
				},
				{
					fieldLabel: 'Account',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'account_name',
					valueField : 'account_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStoreAccount , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{entry_case_text}">' +  
													'<div class="combo-name">'  + 
																" ({account_code}) " 		+ "<br />" 	 + 
																'{account_name}' 			+ 
																
																"[{account_account_case_text}] "		+	
													 "</div>" +  
							 					'</div>';
						}
					},
					name : 'account_id' 
				},
				
				{
	        xtype: 'textfield',
	        name : 'amount',
	        fieldLabel: 'Jumlah'
	      },
		
				{
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

	setSelectedAccount: function( account_id ){
		// console.log("inside set selected original account id ");
		var comboBox = this.down('form').getForm().findField('account_id'); 
		var me = this; 
		var store = comboBox.store;  
		store.load({
			params: {
				selected_id : account_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( account_id );
			}
		});
	},
	
	
	
	setComboBoxData : function( record){
		var me = this; 
		me.setLoading(true);
		
		
		me.setSelectedAccount( record.get("account_id")  ) ; 
	},
	
	setParentData: function( record) {
		this.down('form').getForm().findField('memorial_code').setValue(record.get('code')); 
		this.down('form').getForm().findField('memorial_id').setValue(record.get('id'));
	}
 
});




