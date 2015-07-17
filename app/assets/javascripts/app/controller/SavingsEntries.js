Ext.define('AM.controller.SavingsEntries', {
  extend: 'Ext.app.Controller',

  stores: ['SavingsEntries', 'Members'],
  models: ['SavingsEntry'],

  views: [
    'operation.savingsentry.List',
    'operation.savingsentry.Form',
		'operation.savingsentry.ConfirmationForm',
		'operation.SavingsEntry',
		'operation.GroupLoanList'
  ],

  	refs: [
		{
			ref : "viewport",
			selector : "vp"
		},
		{
			ref : "wrapper",
			selector : "savingsentryProcess"
		},
		{
			ref : 'parentList',
			selector : 'savingsentryProcess operationmemberList'
		},
		{
			ref: 'list',
			selector: 'savingsentrylist'
		},
		{
			ref : 'searchField',
			selector: 'savingsentrylist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
			'savingsentryProcess operationmemberList' : {
				afterrender : this.loadParentObjectList,
				selectionchange: this.parentSelectionChange,
			},
	
      'savingsentrylist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				// afterrender : this.loadObjectList,
				'confirmed' : this.reloadParentRow,
				destroy : this.onDestroy
      },
      'savingsentryform button[action=save]': {
        click: this.updateObject
      },
      'savingsentrylist button[action=addObject]': {
        click: this.addObject
      },

			'savingsentrylist button[action=addLockedObject]': {
        click: this.addLockedObject
      },

			'savingsentrylist button[action=addMembershipObject]': {
        click: this.addMembershipObject
      },

      'savingsentrylist button[action=editObject]': {
        click: this.editObject
      },
      'savingsentrylist button[action=deleteObject]': {
        click: this.deleteObject
      },

			'savingsentrylist button[action=confirmObject]': {
        click: this.confirmObject
			}	,
			
			'confirmsavingsentryform button[action=confirm]' : {
				click : this.executeConfirm
			},
			
			'savingsentrylist button[action=unconfirmObject]': {
        click: this.unconfirmObject
			}	,
			
			'unconfirmsavingsentryform button[action=unconfirm]' : {
				click : this.executeUnconfirm
			},
			
			'savingsentryProcess operationmemberList textfield[name=searchField]': {
        change: this.liveSearch
      }
		
    });
  },

	onDestroy: function(){
		// console.log("on Destroy the savings_entries list ");
		this.getSavingsEntriesStore().loadData([],false);
	},
	
	// try this guy: http://www.learnsomethings.com/2012/02/01/re-selecting-the-last-selected-record-after-store-load-in-extjs4/

	reloadParentRow: function(){
		
		// http://vadimpopa.com/reload-a-single-record-and-refresh-its-extjs-grid-row/
		
		var parentList = this.getParentList();
	
		var wrapper = this.getWrapper();
		modifiedId = wrapper.selectedParentId;
		var me = this; 
		
		
	 
		
		
/*
	// parentList.getView().
	// http://www.sencha.com/forum/showthread.php?258071-How-to-get-an-Element-of-a-grid-row-in-Ext-JS-4&p=945574
	// awesome discussion
	This shite is working.. but the effect is not selected effect
	var node = parentList.getView().getNode(0);
	console.log("The node: " );
	console.log( node );
	
	console.log(parentList.getView().getXType());
	
	result = parentList.getView().highlightItem( node );
*/
		var selectedRecord = parentList.getSelectionModel().getSelection()[0];
		var row = parentList.store.indexOf(selectedRecord);

		// console.log("The row" ) ;
		// console.log( row ) ;

		var node = parentList.getView().getNode(row);
	
		
		
		
		AM.model.Member.load( modifiedId , {
		    scope: parentList,
		    failure: function(record, operation) {
		        //do something if the load failed
		    },
		    success: function(record, operation) {
					
					var store = parentList.getStore(),
					recToUpdate = store.getById(modifiedId);

					recToUpdate.set(record.getData());

					recToUpdate.commit();

					parentList.getView().refreshNode(store.indexOfId(modifiedId));
					
					
					
		    },
		    callback: function(record, operation) {
					// result = parentList.getView().highlightItem( node );
					// console.log("The row: " + row);
					
					// 'savingsentryProcess operationmemberList'   << the selector 
					
					// var textfieldChangeObj = this.eventbus.bus.selectionchange['savingsentryProcess operationmemberList'].Login[0];
					// var textfield = btn.up("form").down("textfield[name='username']");        
					// textfieldChangeObj.suspend(true);
					// textfield.setValue('asasas');
					// textfieldChangeObj.resume(false);
					
					// Ext.util.Observable.suspendEvents(true);
					
					
					// this.suspendEvents();
					// 		node.collapseChildNodes(true);
					// 		this.resumeEvents();
					// 		
					// 		
					// me.suspendEvents(  ) ;
					// parentList.getSelectionModel().select( null );
					// parentList.ClearSelection()
					
					parentList.getSelectionModel().clearSelections()
					
					parentList.getSelectionModel().select( row  );
					// me.resumeEvents(false);
					
					// var rowIndex = me.getMembersStore().find('id', record.getId());  //where 'id': the id field of your model, record.getId() is the method automatically created by Extjs. You can replace 'id' with your unique field.. And 'this' is your store.
					// parentList.getView().select(rowIndex);
		    }
		});
		
	},

	liveSearch : function(grid, newValue, oldValue, options){
		// console.log("Live search is called");
		var me = this;

		me.getMembersStore().getProxy().extraParams = {
		    livesearch: newValue,				// 
		    				// is_deceased : true, 
		    				// is_run_away : true 
		};
	 
		me.getMembersStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},
	
	loadParentObjectList: function(me){
		// delete me.getStore().getProxy().extraParams ;
		me.getStore().getProxy().extraParams = {}
		me.getStore().load(); 
	},
 
	baseAddObject: function( parentObject, savingsStatus ) {
		var view = Ext.widget('savingsentryform');
		view.show();
		view.setParentData(parentObject);
		view.setSavingsStatus( savingsStatus );  
		view.setConditionalTitle( savingsStatus );  
	},
	
	
	// addObject: function() {
	//     
	// 	var parentObject  = this.getParentList().getSelectedObject();
	// 	if( parentObject) {
	// 		var view = Ext.widget('savingsentryform');
	// 		view.show();
	// 		view.setParentData(parentObject);
	// 	}
	//   },

	addObject: function() {
    
		var parentObject  = this.getParentList().getSelectedObject();
		if( parentObject) {
			this.baseAddObject( parentObject, 0);  
		}
  },

	addMembershipObject: function() {
    
		var parentObject  = this.getParentList().getSelectedObject();
		if( parentObject) {
			this.baseAddObject( parentObject, 1);
		}
  },

	addLockedObject: function() {
    
		var parentObject  = this.getParentList().getSelectedObject();
		if( parentObject) {
			this.baseAddObject( parentObject, 2);  
		}
  },
	

	editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
		var parentObject  = this.getParentList().getSelectedObject();
		
		if( parentObject) {
			var view = Ext.widget('savingsentryform');
			view.show();
			view.down('form').loadRecord(record);
			view.setParentData(parentObject);
			view.setConditionalTitle( record.get("savings_status") ); 
		}
		
		
    // var view = Ext.widget('savingsentryform');
    
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');
		var parentList = this.getParentList();
		var wrapper = this.getWrapper();

    var store = this.getSavingsEntriesStore();
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
	 
					store.load({
						params: {
							parent_id : wrapper.selectedParentId 
						}
					});
					 
					
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
			var newObject = new AM.model.SavingsEntry( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
	
					store.load({
						params: {
							parent_id : wrapper.selectedParentId 
						}
					});
					
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
      var store = this.getSavingsEntriesStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
			this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();
  
    if (selections.length > 0) {
			var record = this.getList().getSelectedObject();
      grid.enableRecordButtons();
			
			
    } else {
      grid.disableRecordButtons();
    }
  },


	confirmObject: function(){
		var view = Ext.widget('confirmsavingsentryform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
		view.down('form').getForm().findField('confirmed_at').setValue(record.get('confirmed_at')); 
    view.show();
	},
	
	
	 
 
	
	executeConfirm : function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getSavingsEntriesStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
		// console.log("the values from form");
		// console.log( values );
		// form.setLoading( true ) ;
		// console.log(values['confirmed_at']);
 
		if(record){
			// console.log("The record");
			// console.log( record );
			var rec_id = record.get("id");
			record.set( 'confirmed_at' , values['confirmed_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					confirm: true 
				},
				success : function(record){
					form.setLoading(false);
					
					list.fireEvent('confirmed', record);
					
					// store.load({
					// 	params: {
					// 		booking_id : rec_id
					// 	}
					// });
					
					win.close();
					
					// me.getParentList().getSelectionModel().selectFirstRow();
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
	
	
	
	parentSelectionChange: function(selectionModel, selections) {
		var me = this; 
    var grid = me.getList();
		var parentList = me.getParentList();
		var wrapper = me.getWrapper();
		
		var selectedParentRecord = parentList.getSelectedObject();
		
		// console.log("The selectedParentRecord: " );
		// console.log( selectedParentRecord);
		// if( selectedParentRecord == undefined){
		// 	return;
		// }
		
		// if (typeof(selectedParentRecord) == 'undefined' || selectedParentRecord == null)
		// {
		// 	return; 
		// }
		
		
		var title = "";
		if( selectedParentRecord ){
			title = selectedParentRecord.get("name") + " | " + selectedParentRecord.get("id_number");
		}else{
			title = "";
		}
		grid.setTitle( title );
		
		
		// grid.setTitle( selectedParentRecord.get("name") + " | " + selectedParentRecord.get("id_number"));
		
		// console.log("parent selection change");
		// console.log("The wrapper");
		// console.log( wrapper ) ;

		if (selections.length > 0) {
			grid.enableAddButton();
			// grid.enableRecordButtons();
		} else {
			grid.disableAddButton();
			// grid.disableRecordButtons();
		}
		
		 
		if (parentList.getSelectionModel().hasSelection()) {
			var row = parentList.getSelectionModel().getSelection()[0];
			var id = row.get("id"); 
			wrapper.selectedParentId = id ; 
		}
		
		
		
		// console.log("The parent ID: "+ wrapper.selectedParentId );
		
		// grid.setLoading(true); 
		grid.getStore().getProxy().extraParams.parent_id =  wrapper.selectedParentId ;
		grid.getStore().getProxy().extraParams.is_savings_account =  true ;
		grid.getStore().load(); 
  },

	unconfirmObject: function(){
		// console.log("Inside uncollectObject");
		var view = Ext.widget('unconfirmsavingsentryform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
    view.show();
		// this.reloadRecordView( record, view ) ; 
	},
	
	executeUnconfirm: function(button){
		// console.log("Inside execute Uncollect");
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getSavingsEntriesStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'confirmed_at' , values['confirmed_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					unconfirm: true 
				},
				success : function(record){
					form.setLoading(false);
					
					
					 
					
					list.fireEvent('confirmed', record);
					
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
	

});
