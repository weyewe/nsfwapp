Ext.define('AM.controller.GroupLoans', {
  extend: 'Ext.app.Controller',

  stores: ['GroupLoans'],
  models: ['GroupLoan'],

  views: [
    'operation.grouploan.List',
    'operation.grouploan.Form'
  ],

  	refs: [
		{
			ref: 'list',
			selector: 'grouploanlist'
		},
		{
			ref : 'searchField',
			selector: 'grouploanlist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
      'grouploanlist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'grouploanform button[action=save]': {
        click: this.updateObject
      },
      'grouploanlist button[action=addObject]': {
        click: this.addObject
      },
      'grouploanlist button[action=editObject]': {
        click: this.editObject
      },
      'grouploanlist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'grouploanlist textfield[name=searchField]': {
        change: this.liveSearch
      },


			'grouploanlist button[action=startObject]': {
        click: this.startObject
			}	,
			
			'grouploanlist button[action=unstartObject]': {
        click: this.unstartObject
			}	,
			
			'startgrouploanform button[action=start]' : {
				click : this.executeStart
			},
			
			'unstartgrouploanform button[action=unstart]' : {
				click : this.executeUnstart
			},
			
			'grouploanlist button[action=disburseObject]': {
        click: this.disburseObject
			}	,
			
			'grouploanlist button[action=undisburseObject]': {
        click: this.undisburseObject
			}	,
			
			'disbursegrouploanform button[action=disburse]' : {
				click : this.executeDisburse
			},
			
			'undisbursegrouploanform button[action=undisburse]' : {
				click : this.executeUndisburse
			},
			
			'grouploanlist button[action=closeObject]': {
        click: this.closeObject
			}	,
			
			'closegrouploanform button[action=confirmClose]' : {
				click : this.executeClose
			},
			
			'grouploanlist button[action=withdrawObject]': {
        click: this.withdrawObject
			}	,
			
			'withdrawgrouploanform button[action=confirmWithdraw]' : {
				click : this.executeWithdraw
			},
			
			'grouploanlist button[action=downloadPending]': {
        click: this.downloadPending
			}	,
			
			
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getGroupLoansStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getGroupLoansStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().getProxy().extraParams =  {};
		me.getStore().load();
	},

  addObject: function() {
    var view = Ext.widget('grouploanform');
    view.show();
  },

  editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('grouploanform');

		

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getGroupLoansStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			 
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
			var newObject = new AM.model.GroupLoan( values ) ;
			
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
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getGroupLoansStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
			this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();

    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  },


	startObject: function(){
		// console.log("the startObject callback function");
		var view = Ext.widget('startgrouploanform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
    view.show();
		// this.reloadRecordView( record, view ) ; 
	},
	
	unstartObject: function(){
		// console.log("the startObject callback function");
		var view = Ext.widget('unstartgrouploanform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
    view.show();
		// this.reloadRecordView( record, view ) ; 
	},
	
	executeStart: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoansStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'started_at' , values['started_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					start: true 
				},
				success : function(record){
					form.setLoading(false);
					
					me.reloadRecord( record ) ; 
					
					list.enableRecordButtons(); 
					
					
					win.close();
				},
				failure : function(record,op ){
					// console.log("Fail update");
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					record.reject(); 
					// this.reject(); 
				}
			});
		}
	},
	
	executeUnstart: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoansStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'started_at' , values['started_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					unstart: true 
				},
				success : function(record){
					form.setLoading(false);
					
					me.reloadRecord( record ) ; 
					list.enableRecordButtons(); 
					
					win.close();
				},
				failure : function(record,op ){
					// console.log("Fail update");
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					record.reject(); 
					// this.reject(); 
				}
			});
		}
	},
	
	disburseObject: function(){
		var view = Ext.widget('disbursegrouploanform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
    view.show();

		// this.reloadRecordView( record, view ) ; 
	},
	
	undisburseObject: function(){
		var view = Ext.widget('undisbursegrouploanform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
    view.show();

		// this.reloadRecordView( record, view ) ; 
	},
	
	executeDisburse: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoansStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'disbursed_at' , values['disbursed_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					disburse: true 
				},
				success : function(record){
					form.setLoading(false);
					me.reloadRecord( record ) ; 
					list.enableRecordButtons(); 
					win.close();
				},
				failure : function(record,op ){
					// console.log("Fail update");
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					record.reject(); 
					// this.reject(); 
				}
			});
		}
	},
	
	executeUndisburse: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoansStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'disbursed_at' , values['disbursed_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					undisburse: true 
				},
				success : function(record){
					form.setLoading(false);
					me.reloadRecord( record ) ; 
					list.enableRecordButtons();
					win.close();
				},
				failure : function(record,op ){
					// console.log("Fail update");
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					record.reject(); 
					// this.reject(); 
				}
			});
		}
	},
	
	
	closeObject: function(){
		// console.log("mark as Deceased is clicked");
		var view = Ext.widget('closegrouploanform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
		// view.down('form').getForm().findField('c').setValue(record.get('deceased_at')); 
    view.show();
	},
	
	executeClose : function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoansStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'closed_at' , values['closed_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					close: true 
				},
				success : function(record){
					form.setLoading(false);
					
					// list.fireEvent('confirmed', record);
					
					
					store.load();
					win.close();
					
				},
				failure : function(record,op ){
					// console.log("Fail update");
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					record.reject(); 
					// this.reject(); 
				}
			});
		}
	},
	
	withdrawObject: function(){
		// console.log("mark as Deceased is clicked");
		var view = Ext.widget('withdrawgrouploanform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
		// view.down('form').getForm().findField('c').setValue(record.get('deceased_at')); 
    view.show();
	},
	
	executeWithdraw : function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoansStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'compulsory_savings_withdrawn_at' , values['compulsory_savings_withdrawn_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					withdraw: true 
				},
				success : function(record){
					form.setLoading(false);
					
					// list.fireEvent('confirmed', record);
					
					
					store.load();
					win.close();
					
				},
				failure : function(record,op ){
					// console.log("Fail update");
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					record.reject(); 
					// this.reject(); 
				}
			});
		}
	},
	
	
	
	reloadRecord: function(record){
		
		var list = this.getList();
		var store = this.getList().getStore();
		var modifiedId = record.get('id');
		
		AM.model.GroupLoan.load( modifiedId , {
		    scope: list,
		    failure: function(record, operation) {
		        //do something if the load failed
		    },
		    success: function(record, operation) {
					recToUpdate = store.getById(modifiedId);
					recToUpdate.set(record.getData());
					recToUpdate.commit();
					list.getView().refreshNode(store.indexOfId(modifiedId));
		    },
		    callback: function(record, operation) {
		        //do something whether the load succeeded or failed
		    }
		});
	},
	
	downloadPending: function(){
	 
		
		// var anotherwindow = window.open(
		// 	'reports/billofsale.php?id='+id,'PDF','width='+ps_width+',height='+ps_height+',resizable');
		// console.log("Gonna download pending");
			window.open(
				'group_loans/pending_fulfillment', 'CSV');
				
				
				// var myOtherUrl = 
				       // "http://example.com/index.html?url=" + encodeURIComponent(myUrl);
				
		// window.open( '/bookings/payment_receipt/'+ record.get('id')  );
	},

});
