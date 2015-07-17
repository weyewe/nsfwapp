Ext.define('AM.controller.GroupLoanWeeklyCollections', {
  extend: 'Ext.app.Controller',

  stores: ['GroupLoanWeeklyCollections', 'GroupLoans', 
  			'GroupLoanWeeklyCollectionVoluntarySavingsEntries',
  			'GroupLoanWeeklyCollectionAttendances'],
  models: ['GroupLoanWeeklyCollection'],

  views: [
    'operation.grouploanweeklycollection.List',
		'operation.GroupLoanWeeklyCollection',
		'operation.GroupLoanList'
  ],

  	refs: [
		{
			ref : "wrapper",
			selector : "grouploanweeklycollectionProcess"
		},
		{
			ref : 'parentList',
			selector : 'grouploanweeklycollectionProcess operationgrouploanList'
		},
		{
			ref: 'list',
			selector: 'grouploanweeklycollectionlist'
		},
		
		{
			ref: 'savingsList',
			selector: 'grouploanweeklycollectionvoluntarysavingsentrylist'
		},
		{
			ref: 'attendanceList',
			selector: 'grouploanweeklycollectionattendancelist'
		},
		{
			ref : 'searchField',
			selector: 'grouploanweeklycollectionlist textfield[name=searchField]'
		},
		

	],

  init: function() {
    this.control({
			'grouploanweeklycollectionProcess operationgrouploanList' : {
				afterrender : this.loadParentObjectList,
				selectionchange: this.parentSelectionChange,
			},
	
      'grouploanweeklycollectionlist': {
        // itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				destroy : this.onDestroy
				// afterrender : this.loadObjectList,
      },
      // 'grouploanweeklycollectionform button[action=save]': {
      //   click: this.updateObject
      // },

// we need to add the execution as well
      'grouploanweeklycollectionlist button[action=collectObject]': {
        click: this.collectObject
      },
      'grouploanweeklycollectionlist button[action=confirmObject]': {
        click: this.confirmObject
      },
      
			'grouploanweeklycollectionProcess operationgrouploanList textfield[name=searchField]': {
        change: this.liveSearch
      },

			'grouploanweeklycollectionlist button[action=collectObject]': {
        click: this.collectObject
			}	,
			
			'collectgrouploanweeklycollectionform button[action=collect]' : {
				click : this.executeCollect
			},
			
			'grouploanweeklycollectionlist button[action=uncollectObject]': {
        click: this.uncollectObject
			}	,
			
			'uncollectgrouploanweeklycollectionform button[action=uncollect]' : {
				click : this.executeUncollect
			},
			
			'grouploanweeklycollectionlist button[action=confirmObject]': {
        click: this.confirmObject
			}	,
			
			'confirmgrouploanweeklycollectionform button[action=confirm]' : {
				click : this.executeConfirm
			},
			
			'grouploanweeklycollectionlist button[action=unconfirmObject]': {
        click: this.unconfirmObject
			}	,
			
			'unconfirmgrouploanweeklycollectionform button[action=unconfirm]' : {
				click : this.executeUnconfirm
			},
			
			
			// related to the savings entry
			
	'grouploanweeklycollectionvoluntarysavingsentrylist': {
	    // itemdblclick: this.editObject,
	    selectionchange: this.savingsGridSelectionChange 
      },

      'grouploanweeklycollectionattendancelist': {
	    // itemdblclick: this.editObject,
	    selectionchange: this.attendanceGridSelectionChange 
      },

    'grouploanweeklycollectionattendanceform button[action=save]': {
        click: this.updateAttendanceObject
     },

    'grouploanweeklycollectionattendancelist button[action=editObject]': {
      click: this.editAttendanceObject
    },

	'grouploanweeklycollectionvoluntarysavingsentrylist button[action=addObject]': {
      click: this.addSavingsObject
    },
	
	'grouploanweeklycollectionvoluntarysavingsentryform button[action=save]': {
        click: this.updateSavingsObject
     },

    'grouploanweeklycollectionvoluntarysavingsentrylist button[action=editObject]': {
      click: this.editSavingsObject
    },
	    'grouploanweeklycollectionvoluntarysavingsentrylist button[action=deleteObject]': {
	      click: this.deleteSavingsObject
	    },

	    'grouploanweeklycollectionlist button[action=downloadFormObject]': {
        	click: this.downloadCollectionForm
		}	,
    });
  },

  	downloadCollectionForm: function(){
  		var me  = this;
		var record = this.getList().getSelectedObject();

		
		
		window.open( '/print_weekly_collection/' +  record.get("id") + '.pdf' , "_blank");
  	},

	onDestroy: function(){
		// console.log("on Destroy the savings_entries list ");
		this.getGroupLoanWeeklyCollectionsStore().loadData([],false);
	},

	liveSearch : function(grid, newValue, oldValue, options){
		// console.log("This is the live search from WeeklyCollectios");
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

  

	savingsGridSelectionChange : function( selectionModel, selections){
		var grid = this.getList();
		var savingsGrid = this.getSavingsList();
		
		// if( savingsGrid ){
		// 	console.log( savingsGrid);
		// 	alert("The savings grid is here");
		// } 
	  
	    if (selections.length > 0) {
				savingsGrid.enableRecordButtons();
	    } else {
				savingsGrid.disableRecordButtons();
	    }

		 
	},

	attendanceGridSelectionChange : function( selectionModel, selections){
		var grid = this.getList();
		var attendanceGrid = this.getAttendanceList();
		
		// if( savingsGrid ){
		// 	console.log( savingsGrid);
		// 	alert("The savings grid is here");
		// } 
	  
	    if (selections.length > 0) {
				attendanceGrid.enableRecordButtons();
	    } else {
				attendanceGrid.disableRecordButtons();
	    }

		 
	},

  selectionChange: function(selectionModel, selections) {
		// alert("Selection change on the group loan weekly colelction");
		
		
    var grid = this.getList();
	var savingsGrid = this.getSavingsList();
	var attendanceGrid = this.getAttendanceList();
		
		// if( savingsGrid ){
		// 	console.log( savingsGrid);
		// 	alert("The savings grid is here");
		// } 
  
    if (selections.length > 0) {
      grid.enableRecordButtons();
	  savingsGrid.addObjectButton.enable();  
    } else {
      grid.disableRecordButtons();
			savingsGrid.addObjectButton.disable();  
			savingsGrid.disableRecordButtons();
    }

		var selectedListId; 

		if (grid.getSelectionModel().hasSelection()) {
			 
			var row = grid.getSelectionModel().getSelection()[0];
			selectedListId = row.get("id"); 
			
			var title = "";
			if( row ){
				title = "Weekly Collection Voluntary Savings, Week: " + row.get("week_number");
			}else{
				title = "";
			}
			savingsGrid.setTitle( title );

			var title = "";
			if( row ){
				title = "Attendance, Week: " + row.get("week_number");
			}else{
				title = "";
			}
			attendanceGrid.setTitle( title );

			


		}
		
		savingsGrid.getStore().getProxy().extraParams.parent_id =  selectedListId ;
		savingsGrid.getStore().load();

		attendanceGrid.getStore().getProxy().extraParams.parent_id =  selectedListId ;
		attendanceGrid.getStore().load();
		
		
  },

	parentSelectionChange: function(selectionModel, selections) {
		var me = this; 
    	var grid = me.getList();
		var parentList = me.getParentList();
		var wrapper = me.getWrapper();
		var savingsGrid = this.getSavingsList(); 
		var attendanceGrid = this.getAttendanceList(); 
		
		
		
	 
		 
		if (parentList.getSelectionModel().hasSelection()) {
			
			savingsGrid.getStore().loadData([], false);
			attendanceGrid.getStore().loadData([], false);
			var row = parentList.getSelectionModel().getSelection()[0];
			var id = row.get("id"); 
			
			var title = "";
			if( row ){
				title = "GroupLoan: " + row.get("name");
			}else{
				title = "";
			}
			grid.setTitle( title );
			
			wrapper.selectedParentId = id ; 
			
			savingsGrid.setTitle(null );
			attendanceGrid.setTitle(null)
			// empty out the savingsGrid
		}
		
		grid.getStore().getProxy().extraParams.parent_id =  wrapper.selectedParentId ;
		grid.getStore().load(); 
		
  },

	collectObject: function(){
		var view = Ext.widget('collectgrouploanweeklycollectionform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
    view.show();
		// this.reloadRecordView( record, view ) ; 
	},
	
	uncollectObject: function(){
		// console.log("Inside uncollectObject");
		var view = Ext.widget('uncollectgrouploanweeklycollectionform');
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

    var store = this.getGroupLoanWeeklyCollectionsStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
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
					list.enableRecordButtons();
					// store.load();
					
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
	
	executeUncollect: function(button){
		// console.log("Inside execute Uncollect");
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoanWeeklyCollectionsStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
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
					uncollect: true 
				},
				success : function(record){
					form.setLoading(false);
					
					
					me.reloadRecord( record ) ; 
					list.enableRecordButtons();
					// store.load();
					
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
	
	confirmObject: function(){
		var view = Ext.widget('confirmgrouploanweeklycollectionform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
    view.show();
		// this.reloadRecordView( record, view ) ; 
	},
	
	unconfirmObject: function(){
		var view = Ext.widget('unconfirmgrouploanweeklycollectionform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
    view.show();
		// this.reloadRecordView( record, view ) ; 
	},
	
	executeConfirm: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoanWeeklyCollectionsStore();
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
					confirm: true 
				},
				success : function(record){
					form.setLoading(false);
					
					me.reloadRecord( record ) ; 
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
	
	executeUnconfirm: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getGroupLoanWeeklyCollectionsStore();
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
					
					me.reloadRecord( record ) ; 
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
		// console.log("Inside reload record");
		// console.log( record );
		var list = this.getList();
		var store = this.getList().getStore();
		var modifiedId = record.get('id');
		
		AM.model.GroupLoanWeeklyCollection.load( modifiedId , {
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
	
	
	



	editAttendanceObject: function() {
		var me = this; 
		var parentObject  = this.getList().getSelectedObject();
 	   var record = this.getAttendanceList().getSelectedObject();

 	   console.log( record );
		
		 
		if( parentObject) { 
			var view = Ext.widget('grouploanweeklycollectionattendanceform');
	

	   	 	view.down('form').loadRecord(record);
			view.show();
		}
  },

  updateAttendanceObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');
		var parentList = this.getParentList();
		
		var groupLoanWeeklyCollectionId = this.getList().getSelectedObject().get("id");
		var wrapper = this.getWrapper();

    var store = this.getGroupLoanWeeklyCollectionAttendancesStore();
    var record = form.getRecord();
    var values = form.getValues();

// console.log("The values: " ) ;
// console.log( values );

		
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
	 
					store.load({
						params: {
							parent_id : groupLoanWeeklyCollectionId
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
			var newObject = new AM.model.GroupLoanWeeklyCollectionAttendance( values ) ;
			form.query('checkbox').forEach(function(checkbox){
				record.set( checkbox['name']  ,checkbox['checked'] ) ;
			});
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
	
					store.load({
						params: {
							parent_id : groupLoanWeeklyCollectionId
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


	/*
	FOR THE SAVINGS
	*/
	
	addSavingsObject: function() {
	 
		var parentObject  = this.getList().getSelectedObject();
		 
		if( parentObject) { 
			var view = Ext.widget('grouploanweeklycollectionvoluntarysavingsentryform');
			 
			view.setExtraParamForJsonRemoteStore( parentObject.get("id")); 
			view.setParentData( parentObject );
			view.show();
		}
 	 },

  editSavingsObject: function() {
		var me = this; 
		var parentObject  = this.getList().getSelectedObject();
 	   var record = this.getSavingsList().getSelectedObject();

		
		 
		if( parentObject) { 
			var view = Ext.widget('grouploanweeklycollectionvoluntarysavingsentryform');
			 
			view.setExtraParamForJsonRemoteStore( parentObject.get("id")); 
			view.setComboBoxData( record );

			view.setParentData( parentObject );

	    view.down('form').loadRecord(record);
			view.show();
		}
  },

  updateSavingsObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');
		var parentList = this.getParentList();
		
		var groupLoanWeeklyCollectionId = this.getList().getSelectedObject().get("id");
		var wrapper = this.getWrapper();

    var store = this.getGroupLoanWeeklyCollectionVoluntarySavingsEntriesStore();
    var record = form.getRecord();
    var values = form.getValues();

// console.log("The values: " ) ;
// console.log( values );

		
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
							parent_id : groupLoanWeeklyCollectionId
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
			var newObject = new AM.model.GroupLoanWeeklyCollectionVoluntarySavingsEntry( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
	
					store.load({
						params: {
							parent_id : groupLoanWeeklyCollectionId
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

  deleteSavingsObject: function() {
    var record = this.getSavingsList().getSelectedObject();

		

    if (record) {
			var group_loan_weekly_collection_id = record.get('group_loan_weekly_collection_id');
      var store = this.getSavingsList().getStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically

			this.getSavingsList().getStore().getProxy().extraParams.parent_id =  group_loan_weekly_collection_id ;


			this.getSavingsList().query('pagingtoolbar')[0].doRefresh();
    }

  },

});
