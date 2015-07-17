Ext.define('AM.view.master.branch.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.branchform',

  title : 'Add / Edit Branch',
  layout: 'fit',
	width	: 500,
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
	      }
	      ,{
				xtype: 'textarea',
				name : 'description',
				fieldLabel: 'Deskripsi'
			},
			{
				xtype: 'textarea',
				name : 'address',
				fieldLabel: 'Alamat'
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

});

