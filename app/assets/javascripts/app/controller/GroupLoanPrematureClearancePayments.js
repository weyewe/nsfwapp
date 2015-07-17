Ext.define('AM.controller.GroupLoanPrematureClearancePayments', {
  extend: 'Ext.app.Controller',

  stores: ['GroupLoanPrematureClearancePayments', 'GroupLoans'],
  models: ['GroupLoanPrematureClearancePayment'],

  views: [
    'operation.grouploanprematureclearancepayment.List',
    'operation.grouploanprematureclearancepayment.Form',
		'operation.GroupLoanPrematureClearancePayment',
		'operation.GroupLoanList'
  ],

  	refs: [
		{
			ref : "wrapper",
			selector : "grouploanprematureclearancepaymentProcess"
		},
		{
			ref : 'parentList',
			selector : 'grouploanprematureclearancepaymentProcess operationgrouploanList'
		},
		{
			ref: 'list',
			selector: 'grouploanprematureclearancepaymentlist'
		},
		{
			ref : 'searchField',
			selector: 'grouploanprematureclearancepaymentlist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
			'grouploanprematureclearancepaymentProcess operationgrouploanList' : {
				afterrender : this.loadParentObjectList,
				selectionchange: this.parentSelectionChange,
			},
	
      'grouploanprematureclearancepaymentlist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				destroy : this.onDestroy
				// afterrender : this.loadObjectList,
      },
      'grouploanprematureclearancepaymentform button[action=save]': {
        click: this.updateObject
      },
      'grouploanprematureclearancepaymentlist button[action=addObject]': {
        click: this.addObject
      },
      'grouploanprematureclearancepaymentlist button[action=editObject]': {
        click: this.editObject
      },
      'grouploanprematureclearancepaymentlist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'grouploanprematureclearancepaymentProcess operationgrouploanList  textfield[name=searchField]': {
        change: this.liveSearch
      }
		
    });
  },
	
	onDestroy: function(){
		// console.log("on Destroy the savings_entries list ");
		this.getGroupLoanPrematureClearancePaymentsStore().loadData([],false);
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
			var view = Ext.widget('grouploanprematureclearancepaymentform');
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
	    var view = Ext.widget('grouploanprematureclearancepaymentform');
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

    var store = this.getGroupLoanPrematureClearancePaymentsStore();
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
			var newObject = new AM.model.GroupLoanPrematureClearancePayment( values ) ;
			
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
      var store = this.getGroupLoanPrematureClearancePaymentsStore();
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

});
