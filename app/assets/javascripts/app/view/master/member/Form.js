Ext.define('AM.view.master.member.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.memberform',

  title : 'Add / Edit Member',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'role_search',
			fields	: [
	 				{
						name : 'role_name',
						mapping : "name"
					},
					{
						name : 'role_id',
						mapping : 'id'
					}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_role',
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
	      },{
	        xtype: 'textfield',
	        name : 'name',
	        fieldLabel: ' Name'
	      },{
					xtype: 'textfield',
					name : 'id_number',
					fieldLabel: 'Nomor ID'
				},
				{
					xtype: 'textarea',
					name : 'address',
					fieldLabel: 'Alamat'
				},
				
				{
					xtype: 'numberfield',
					name : 'rt',
					fieldLabel: 'RT'
				},
				
				{
					xtype: 'numberfield',
					name : 'rw',
					fieldLabel: 'RW'
				},
				
				{
					xtype: 'textfield',
					name : 'village',
					fieldLabel: 'Kelurahan'
				},
				
				
				{
					xtype: 'textfield',
					name : 'id_card_number',
					fieldLabel: 'KTP'
				},
				
				
				
				{
					xtype: 'datefield',
					name : 'birthday_date',
					fieldLabel: 'Ulang Tahun',
					format: 'Y-m-d',
				},
				
				
				
				
				{
					fieldLabel : 'Data Lengkap?',
					name : 'is_data_complete',
					xtype : 'checkbox'
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

	// setComboBoxData : function( record){
	// 	// console.log("Inside the Form.. edit.. setComboBox data");
	// 	var role_id = record.get("role_id");
	// 	var comboBox = this.down('form').getForm().findField('role_id'); 
	// 	var me = this; 
	// 	var store = comboBox.store; 
	// 	store.load({
	// 		params: {
	// 			selected_id : role_id 
	// 		},
	// 		callback : function(records, options, success){
	// 			me.setLoading(false);
	// 			comboBox.setValue( role_id );
	// 		}
	// 	});
	// }
});

