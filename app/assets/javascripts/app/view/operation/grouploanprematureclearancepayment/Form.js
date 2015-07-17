Ext.define('AM.view.operation.grouploanprematureclearancepayment.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.grouploanprematureclearancepaymentform',

  title : 'Add / Edit GroupLoanPrematureClearancePayment',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true,  
	 
 
  initComponent: function() {
		var me = this; 
		
		var localJsonStoreClearanceCase = Ext.create(Ext.data.Store, {
			type : 'array',
			storeId : 'uncollectible_clearance_case_search',
			fields	: [ 
				{ name : "clearance_case"}, 
				{ name : "clearance_case_text"}  
			], 
			data : [
				{ clearance_case : 1, clearance_case_text : "Pemotongan Tabungan Wajib"},
				{ clearance_case : 2, clearance_case_text : "Pembayaran Tunai"}
			] 
		});
		

		var remoteJsonStoreGroupLoanMembership = Ext.create(Ext.data.JsonStore, {
			storeId : 'glm_search',
			fields	: [
			 		{
						name : 'member_name',
						mapping : "member_name"
					} ,
					{
						name : 'member_id_number',
						mapping : "member_id_number"
					},
					{
						name : 'group_loan_id',
						mapping : "group_loan_id"
					},
					{
						name : 'group_loan_membership_id',
						mapping : 'id'
					},
					
			],
			// grid.getStore().getProxy().extraParams.parent_id =  wrapper.selectedParentId
			proxy  	: { 
				extraParams : {
					parent_id : null
				},
				type : 'ajax',
				url : 'api/search_group_loan_memberships',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			},
			autoLoad : false 
		});
		
		var remoteJsonStoreGroupLoanWeeklyCollection = Ext.create(Ext.data.JsonStore, {
			storeId : 'glwc_search',
			fields	: [
			 		{
						name : 'group_loan_weekly_collection_week_number',
						mapping : "week_number"
					}, 
					{
						name : 'group_loan_weekly_collection_id',
						mapping : 'id'
					}
			],
			proxy  	: {
				extraParams : {
					parent_id : null
				},
				type : 'ajax',
				url : 'api/search_group_loan_weekly_collections',
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
	        name : 'group_loan_id',
	        fieldLabel: 'GroupLoan ID'
	      },
				{
					xtype: 'displayfield',
					fieldLabel: 'Group Loan:',
					name: 'group_loan_name' ,
					value : '10' 
				},
				{
					fieldLabel: 'Minggu Pengajuan',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'group_loan_weekly_collection_week_number',
					valueField : 'group_loan_weekly_collection_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStoreGroupLoanWeeklyCollection , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{group_loan_weekly_collection_week_number}">' +  
													'<div class="combo-name">{group_loan_weekly_collection_week_number}</div>' +
							 					'</div>';
						}
					},
					name : 'group_loan_weekly_collection_id' 
				},
				
				{
					fieldLabel: 'Member',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'member_name',
					valueField : 'group_loan_membership_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStoreGroupLoanMembership, 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{member_name}">' +  
													'<div class="combo-name">{member_name}</div>' +
													'<div class="combo-name">{member_id_number}</div>' +  
							 					'</div>';
						}
					},
					name : 'group_loan_membership_id' 
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

	setSelectedGroupLoanWeeklyCollection: function( group_loan_weekly_collection_id ){
		var comboBox = this.down('form').getForm().findField('group_loan_weekly_collection_id'); 
		var me = this; 
		var store = comboBox.store;  
		store.load({
			params: {
				selected_id : group_loan_weekly_collection_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( group_loan_weekly_collection_id );
			}
		});
	},
	
	setSelectedGroupLoanMembership: function( group_loan_membership_id ){
		var comboBox = this.down('form').getForm().findField('group_loan_membership_id'); 
		var me = this; 
		var store = comboBox.store;  
		store.load({
			params: {
				selected_id : group_loan_membership_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( group_loan_membership_id );
			}
		});
	},
	

	
	setExtraParamInGroupLoanMembershipComboBox: function( parent_id ){
		var comboBox = this.down('form').getForm().findField('group_loan_membership_id'); 
		var store = comboBox.store;
		
		store.getProxy().extraParams.parent_id =  parent_id;
	},
	
	setExtraParamInGroupLoanWeeklyCollectionComboBox: function(parent_id){
		var comboBox = this.down('form').getForm().findField('group_loan_weekly_collection_id'); 
		var store = comboBox.store;
		
		store.getProxy().extraParams.parent_id =  parent_id;
	},
	
	
	setComboBoxExtraParams: function( parent_id ) {
		var me =this;
		me.setExtraParamInGroupLoanMembershipComboBox( parent_id );
		me.setExtraParamInGroupLoanWeeklyCollectionComboBox( parent_id );
	},
	
	

	setComboBoxData : function( record){ 
		var me = this; 
		me.setLoading(true);
		me.setSelectedGroupLoanMembership( record.get("group_loan_membership_id")  ) ;
		me.setSelectedGroupLoanWeeklyCollection( record.get("group_loan_weekly_collection_id")  ) ;
	},
	
	setParentData: function( record ){ 
		this.down('form').getForm().findField('group_loan_name').setValue(record.get('name')); 
		this.down('form').getForm().findField('group_loan_id').setValue(record.get('id')); 
	},
});

