Ext.define('AM.controller.GroupLoanWeeklyUncollectibles', {
  extend: 'Ext.app.Controller',

  stores: ['GroupLoanWeeklyUncollectibles', 'GroupLoans'],
  models: ['GroupLoanWeeklyUncollectible'],

  views: [
    'operation.grouploanweeklyuncollectible.List',
    'operation.grouploanweeklyuncollectible.Form',
		'operation.GroupLoanWeeklyUncollectible',
		'operation.GroupLoanList'
  ],

  	refs: [
		{
			ref : "wrapper",
			selector : "grouploanweeklyuncollectibleProcess"
		},
		{
			ref : 'parentList',
			selector : 'grouploanweeklyuncollectibleProcess operationgrouploanList'
		},
		{
			ref: 'list',
			selector: 'grouploanweeklyuncollectiblelist'
		},
		{
			ref : 'searchField',
			selector: 'grouploanweeklyuncollectiblelist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
			'grouploanweeklyuncollectibleProcess operationgrouploanList' : {
				afterrender : this.loadParentObjectList,
				selectionchange: this.parentSelectionChange,
			},
	
      'grouploanweeklyuncollectiblelist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				destroy : this.onDestroy
				// afterrender : this.loadObjectList,
      },
      'grouploanweeklyuncollectibleform button[action=save]': {
        click: this.updateObject
      },
      'grouploanweeklyuncollectiblelist button[action=addObject]': {
        click: this.addObject
      },
      'grouploanweeklyuncollectiblelist button[action=editObject]': {
        click: this.editObject
      },
      'grouploanweeklyuncollectiblelist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'grouploanweeklyuncollectibleProcess operationgrouploanList  textfield[name=searchField]': {
        change: this.liveSearch
      },

			'grouploanweeklyuncollectiblelist button[action=collectObject]': {
        click: this.collectObject
			}	,
			
			'collectgrouploanweeklyuncollectibleform button[action=collect]' : {
				click : this.executeCollect
			},
			
			'grouploanweeklyuncollectiblelist button[action=clearObject]': {
        click: this.clearObject
			}	,
			
			'cleargrouploanweeklyuncollectibleform button[action=clear]' : {
				click : this.executeClear
			},
		
    });
  },


	onDestroy: function(){
		// console.log("on Destroy the savings_entries list ");
		this.getGroupLoanWeeklyUncollectiblesStore().loadData([],false);
	},
	
	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getGroupLoansStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getGroupLoansStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},
	
	loadParentObjectList: function(me){
		// console.log("after render the group_loan list");
		me.getStore().getProxy().extraParams = {};
		me.getStore().load(); 
	},

  addObject: function() {
    
		var parentObject  = this.getParentList().getSelectedObject();
		if( parentObject) {
			var view = Ext.widget('grouploanweeklyuncollectibleform');
			view.show();
			
			view.setComboBoxExtraParams(parentObject.get("id")); 
			view.setParentData(parentObject);
		}
  },

  editObject: function() {
		var me = this; 
		
		var parentObject  = this.getParentList().getSelectedObject();
		if( parentObject) {
			var record = this.getList().getSelectedObject();
	    var view = Ext.widget('grouploanweeklyuncollectibleform');
			view.show();
			view.setComboBoxExtraParams(parentObject.get("id")); 
			// view.updateExtraParamsInComboBox( parentObject.get("id") );
			
			view.setComboBoxData( record );
			// view.setParentData(parentObject);
	    view.down('form').loadRecord(record);
		}
    
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');
		var parentList = this.getParentList();
		var wrapper = this.getWrapper();

    var store = this.getGroupLoanWeeklyUncollectiblesStore();
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
			var newObject = new AM.model.GroupLoanWeeklyUncollectible( values ) ;
			
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
      var store = this.getGroupLoanWeeklyUncollectiblesStore();
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

	parentSelectionChange: function(selectionModel, selections) {
		var me = this; 
    var grid = me.getList();
		var parentList = me.getParentList();
		var wrapper = me.getWrapper();
		
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
		grid.getStore().load(); 
  },

	collectObject: function(){
		// console.log("inside collectObject");
		var view = Ext.widget('collectgrouploanweeklyuncollectibleform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
    view.show();
		// this.reloadRecordView( record, view ) ; 
	},
	
	executeCollect: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoanWeeklyUncollectiblesStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();

		// console.log("Inside executeCollect:");
		// console.log( record ) ;
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'collected_at' , values['collected_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					collect: true 
				},
				success : function(record){
					form.setLoading(false);
					
					me.reloadRecord( record ) ; 
					
					
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
	
	clearObject: function(){
		// console.log("inside clearObject");
		var view = Ext.widget('cleargrouploanweeklyuncollectibleform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
    view.show();
		// this.reloadRecordView( record, view ) ; 
	},
	
	executeClear: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoanWeeklyUncollectiblesStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();

		// console.log("Inside executeClear:");
		// console.log( record ) ;
		
		console.log("inside execute clear");
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'cleared_at' , values['cleared_at'] );
			console.log("The cleared_at : " + record.get("cleared_at"));
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					clear: true 
				},
				success : function(record){
					form.setLoading(false);
					
					me.reloadRecord( record ) ; 
					
					
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
		console.log("Inside reloadRecord");
		
		var list = this.getList();
		var store = this.getList().getStore();
		var modifiedId = record.get('id');
		
		AM.model.GroupLoanWeeklyUncollectible.load( modifiedId , {
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

});
