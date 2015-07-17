Ext.define('AM.view.operation.grouploanmembership.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.grouploanmembershipform',

  title : 'Add / Edit GroupLoanMembership',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
		var me = this; 
		
		var remoteJsonStoreMember = Ext.create(Ext.data.JsonStore, {
			storeId : 'member_search',
			fields	: [
			 		{
						name : 'member_name',
						mapping : "name"
					} ,
					{
						name : 'member_id_number',
						mapping : "id_number"
					} ,
					{
						name : 'member_address',
						mapping : "address"
					} ,
					{
						name : 'member_id',
						mapping : 'id'
					},
					{
						name : 'display',
						convert: function(v, rec){
							var name = rec.get('member_name') ;
							var id_number = rec.get("member_id_number");
							
							return name + "("+  id_number +    ")"; 
						} 
					}
					
			],
			
		 
			proxy  	: {
				type : 'ajax',
				url : 'api/search_members',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			},
			autoLoad : false 
		});
		
		var remoteJsonStoreGroupLoanProduct = Ext.create(Ext.data.JsonStore, {
			storeId : 'glp_search',
			fields	: [
			 		{
						name : 'group_loan_product_name',
						mapping : "name"
					} ,
					{
						name : 'group_loan_product_interest',
						mapping : "interest"
					} ,
					{
						name : 'group_loan_product_principal',
						mapping : "principal"
					} ,
					{
						name : 'group_loan_product_compulsory_savings',
						mapping : "compulsory_savings"
					} ,
					{
						name : 'group_loan_product_admin_fee',
						mapping : "admin_fee"
					} ,
					{
						name : 'group_loan_product_total_weeks',
						mapping : "total_weeks"
					} ,
					{
						name : 'group_loan_product_id',
						mapping : 'id'
					},
					{
						name : 'display',
						convert: function(v, rec){
							var name = rec.get('group_loan_product_name') ;
							var duration = rec.get("group_loan_product_total_weeks");
							
							return name + "("+  duration +    " weeks)"; 
						} 
					}
					
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_group_loan_products',
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
					fieldLabel: 'Produk',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'display',
					valueField : 'group_loan_product_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStoreGroupLoanProduct , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{group_loan_product_name}">' + 
													'<div class="combo-name">{group_loan_product_name}</div>' + 
													'<div class="combo-name">Principal: {group_loan_product_principal}</div>' + 
													'<div class="combo-name">Interest: {group_loan_product_interest}</div>' +  
													'<div class="combo-name">Tabungan Wajib: {group_loan_product_compulsory_savings}</div>' +  
													'<div class="combo-name">Admin: {group_loan_product_admin_fee}</div>' +  
													'<div class="combo-name">Durasi: {group_loan_product_total_weeks}</div>' +  
							 					'</div>';
						}
					},
					name : 'group_loan_product_id' 
				},
				
				{
					fieldLabel: 'Member',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'display' ,
					valueField : 'member_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStoreMember, 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{member_name}">' +   
													'<div class="combo-name">{member_name}</div>' +  
													'<div class="combo-name">{member_id_number}</div>' +  
													'<div class="combo-name">{member_address}</div>' + 
							 					'</div>';
						}
					},
					name : 'member_id'  
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

	setSelectedGroupLoanProduct: function( group_loan_product_id ){
		var comboBox = this.down('form').getForm().findField('group_loan_product_id'); 
		var me = this; 
		var store = comboBox.store; 
		// console.log( 'setSelectedGLP');
		// console.log( store ) ;
		store.load({
			params: {
				selected_id : group_loan_product_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( group_loan_product_id );
			}
		});
	},
	
	setSelectedMember: function( member_id ){
		var comboBox = this.down('form').getForm().findField('member_id'); 
		var me = this; 
		var store = comboBox.store; 
		// console.log( 'setSelectedMember');
		// console.log( store ) ;
		store.load({
			params: {
				selected_id : member_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( member_id );
			}
		});
	},

	setComboBoxData : function( record){
		// console.log("gonna set combo box data");
		var me = this; 
		me.setLoading(true);
		
		
		
		// console.log("member_id: "+ record.get("member_id") );
		// console.log( "glp_id: " + record.get("group_loan_product_id") );
		me.setSelectedMember( record.get("member_id")  ) ;
		me.setSelectedGroupLoanProduct( record.get("group_loan_product_id")  ) ;
	},
	
	setParentData: function( record ){
		this.down('form').getForm().findField('group_loan_name').setValue(record.get('name')); 
		this.down('form').getForm().findField('group_loan_id').setValue(record.get('id')); 
	},
});

