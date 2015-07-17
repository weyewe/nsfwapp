Ext.define('AM.controller.Accounts', {
  extend: 'Ext.app.Controller',

  stores: ['Accounts'],
  models: ['Account'],

  views: [
    'operation.Account',
		'operation.account.ChartOfAccounts'
    // 'booking.customer.Form'
  ],

	refs: [
		{
			ref: 'list',
			selector: 'coalist'
		} 
	],

  init: function() {
    this.control({
      'coalist': {
        // itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'accountform button[action=save]': {
        click: this.updateObject
      },
      'coalist button[action=addObject]': {
        click: this.addObject
      },
      'coalist button[action=editObject]': {
        click: this.editObject
      },
      'coalist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'coalist textfield[name=searchField]': {
        change: this.liveSearch
      }
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getAccountsStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getAccountsStore().load();
	},
 

	loadObjectList : function(me){
		// console.log("Gonna load object list");
		me.getStore().load();
		
		// console.log("Done loading object list");
	},

  addObject: function() {
		
		var sm = this.getList().getSelectionModel();
		var sel = sm.getSelection();
 
		var record = sel[0] ;  
		
		if( record){
			var view = Ext.widget('accountform');
			view.show();
			view.setParentData(record);
		}
  },

  editObject: function() {
		var me = this;  
		
    
		var sm = me.getList().getSelectionModel();
		var sel = sm.getSelection();
 
		var record = sel[0] ;  
		
		if( record ) {
			var view = Ext.widget('accountform');
			view.down('form').loadRecord(record);
			view.setComboBoxData(record); 
		}

    
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getAccountsStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			
			form.query('checkbox').forEach(function(checkbox){
				record.set( checkbox['name']  ,checkbox['checked'] ) ;
			});
			
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					
					// store.getProxy().extraParams = {
					//     livesearch: ''
					// };
	 
					store.load();
					win.close();
				},
				failure : function(record,op ){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
				
			 
		}else{
			//  no record at all  => gonna create the new one 
			var me  = this; 
			var newObject = new AM.model.Account( values ) ;
			
			form.query('checkbox').forEach(function(checkbox){
				newObject.set( checkbox['name']  ,checkbox['checked'] ) ;
			});
			
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
	
					store.load();
					form.setLoading(false);
					win.close();
					
				},
				failure: function( record, op){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
		} 
  },

  deleteObject: function() {
    // var record = this.getList().getSelectedObject();
		var sm = this.getList().getSelectionModel();
		var sel = sm.getSelection();
 
		var record = sel[0] ;

    if (record) {
      var store = this.getAccountsStore();
			record.remove(true);
			// store.sync();
      // store.remove(record);
      // store.sync();
// to do refresh programmatically
			// this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();

		// console.log("on selection change.. show the record buttons");
		var sm = this.getList().getSelectionModel();
		var sel = sm.getSelection();
 
		var record = sel[0] ;
		
		
    if ( record ) {
      grid.enableRecordButtons(record);
    } else {
      grid.disableRecordButtons();
    }
  }

});
