Ext.define('AM.view.master.employee.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.employeeform',

  title : 'Add / Edit Employee',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {

  	var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'branch_search',
			fields	: [
	 				{
						name : 'branch_name',
						mapping : "name"
					},
					{
						name : 'branch_id',
						mapping : 'id'
					},
					{
						name : 'branch_code',
						mapping : 'code'
					},
					{
						name : 'branch_description',
						mapping : 'descrition'
					},
					{
						name : 'branch_address',
						mapping : 'address'
					}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_branches',
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
	        fieldLabel: ' Nama'
	      },
	      {
	        xtype: 'textfield',
	        name : 'code',
	        fieldLabel: ' Kode Cabang'
	      },
	      {
			xtype: 'textarea',
			name : 'description',
			fieldLabel: 'Deskripsi'
		  },
		  {
				fieldLabel: 'Cabang',
				xtype: 'combo',
				queryMode: 'remote',
				forceSelection: true, 
				displayField : 'branch_code',
				valueField : 'branch_id',
				pageSize : 5,
				minChars : 1, 
				allowBlank : false, 
				triggerAction: 'all',
				store : remoteJsonStore , 
				listConfig : {
					getInnerTpl: function(){
						return  	'<div data-qtip="{branch_code}">' + 
												'<div class="combo-name">{branch_codes}</div>' + 
												'<div class="combo-name">Name: {branch_name}</div>'  
						 					'</div>';
					}
				},
				name : 'branch_id' 
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

  setSelectedBranch: function( branch_id ){
		var comboBox = this.down('form').getForm().findField('branch_id'); 
		var me = this; 
		var store = comboBox.store; 
		// console.log( 'setSelectedMember');
		// console.log( store ) ;
		store.load({
			params: {
				selected_id : branch_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( branch_id );
			}
		});
	},


  setComboBoxData : function( record){
		// console.log("gonna set combo box data");
		var me = this; 
		me.setLoading(true);
		me.setSelectedBranch( record.get("branch_id")  ) ;
	},


});

