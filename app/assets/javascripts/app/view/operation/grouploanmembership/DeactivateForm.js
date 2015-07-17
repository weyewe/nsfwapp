Ext.define('AM.view.operation.grouploanmembership.DeactivateationForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.deactivategrouploanmembershipform',

  title : 'Deactivate SavingsEntry',
  layout: 'fit',
	width	: 400,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	
		var localJsonStoreDeactivationCase = Ext.create(Ext.data.Store, {
			type : 'array',
			storeId : 'glm_deactivation_case',
			fields	: [ 
				{ name : "deactivation_case"}, 
				{ name : "deactivation_case_name"}  
			], 
			data : [
				{ deactivation_case : 1, deactivation_case_name : "Absen di Pendidikan Keuangan"},
				{ deactivation_case : 2, deactivation_case_name : "Absen di Pencairan Pinjaman"}
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
					xtype: 'displayfield',
					fieldLabel: 'Group Loan',
					name: 'group_loan_name' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Member Name',
					name: 'member_name' 
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Member ID',
					name: 'member_id_number' 
				},
				{
					fieldLabel: 'Kasus non-aktif',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'deactivation_case_name',
					valueField : 'deactivation_case',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : localJsonStoreDeactivationCase, 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{deactivation_case_name}">' +  
													'<div class="combo-name">{deactivation_case_name}</div>' +
							 					'</div>';
						}
					},
					name : 'deactivation_case' 
				}
		 
			]
    }];

    this.buttons = [{
      text: 'Confirm',
      action: 'confirmDeactivate'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	setParentData: function( record ) {
		this.down('form').getForm().findField('group_loan_name').setValue(record.get('group_loan_name')); 
		this.down('form').getForm().findField('member_id_number').setValue(record.get('member_id_number')); 
		this.down('form').getForm().findField('member_name').setValue(record.get('member_name')); 
		this.down('form').getForm().findField('deactivation_case').setValue(record.get('deactivation_case')); 
	}
});
