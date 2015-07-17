Ext.define('AM.view.operation.grouploanweeklycollection.voluntarysavingsentry.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.grouploanweeklycollectionvoluntarysavingsentryform',

  title : 'Add / Edit Voluntary Savings',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
 
	remoteJsonStore : null,
	
	setExtraParamForJsonRemoteStore: function(id){
		this.remoteJsonStore.proxy.extraParams = {group_loan_weekly_collection_id: id};
	},


	
  initComponent: function() {
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
	
	 
		var selectedParentId = this.parentId;
		this.remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			// pageSize : 2,
			storeId : 'weekly_collection_active_members',
			fields	: [
	 				{
						name : 'group_loan_membership_id',
						mapping : "group_loan_membership_id"
					},
					{
						name : 'member_name',
						mapping : 'member_name'
					},
					{
						name : 'member_id_number',
						mapping : 'member_id_number'
					},
					{
						name : 'display',
						convert: function(v, rec){
							var name = rec.get('member_name') ;
							var id_number = rec.get("member_id_number");
							
							return name + "("+  id_number +    " )"; 
						} 
					}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/group_loan_weekly_collection/active_group_loan_memberships',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			},
			autoLoad : false 
		});
		
		var LocalRemoteJSONStore = this.remoteJsonStore;
		
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
	        name : 'group_loan_weekly_collection_id',
	        fieldLabel: 'group_loan_weekly_collection_id'
	      },
		 
				 
				{
					fieldLabel: 'Member',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'display',
					valueField : 'group_loan_membership_id',
					// pageSize : 3,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : LocalRemoteJSONStore , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{member_name}">' +  
													'<div class="combo-name">{member_name}</div>' +
													'<div class="combo-name">ID Number: {member_id_number}</div>' +   
							 					'</div>';
						}
					},
					name : 'group_loan_membership_id' 
				},
				{
					xtype: 'textfield',
					name : 'amount',
					fieldLabel: 'Jumlah Tabungan'
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

	setComboBoxData : function( record){
		// console.log("Inside the Form.. edit.. setComboBox data");
		var group_loan_membership_id = record.get("group_loan_membership_id");
		console.log("the glm:  " );
		console.log(group_loan_membership_id  );
		var group_loan_weekly_collection_id = record.get("group_loan_weekly_collection_id");
		var comboBox = this.down('form').getForm().findField('group_loan_membership_id'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				group_loan_weekly_collection_id : group_loan_weekly_collection_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( group_loan_membership_id );
				console.log("done setting value");
				console.log( comboBox );
				console.log( comboBox.getValue() ) ;
			}
		});
	},
	
	setParentData: function( record ){
		// the record is GroupLoanWeeklyCollection 
		this.down('form').getForm().findField('group_loan_weekly_collection_id').setValue(record.get('id')); 
	},
});

