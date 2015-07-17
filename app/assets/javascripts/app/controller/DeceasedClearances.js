Ext.define('AM.controller.DeceasedClearances', {
  extend: 'Ext.app.Controller',

  stores: ['DeceasedClearances', 'Members'],
  models: ['DeceasedClearance'],

  views: [
    'operation.deceasedclearance.List',
    // 'operation.deceasedclearance.Form',
		'operation.DeceasedClearance',
		'operation.GroupLoanList'
  ],

  	refs: [
		{
			ref : "wrapper",
			selector : "deceasedclearanceProcess"
		},
		{
			ref : 'parentList',
			selector : 'deceasedclearanceProcess operationmemberList'
		},
		{
			ref: 'list',
			selector: 'deceasedclearancelist'
		},
		{
			ref : 'searchField',
			selector: 'deceasedclearancelist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
			'deceasedclearanceProcess operationmemberList' : {
				afterrender : this.loadParentObjectList,
				selectionchange: this.parentSelectionChange,
			},
	
      'deceasedclearancelist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				destroy : this.onDestroy
				// afterrender : this.loadObjectList,
      },
      // 'deceasedclearanceform button[action=save]': {
      //   click: this.updateObject
      // },
      // 'deceasedclearancelist button[action=addObject]': {
      //   click: this.addObject
      // },
      // 'deceasedclearancelist button[action=editObject]': {
      //   click: this.editObject
      // },
      'deceasedclearancelist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'deceasedclearanceProcess operationmemberList textfield[name=searchField]': {
        change: this.liveSearch
      }

// savingsentryProcess operationmemberList textfield[name=searchField]
		
    });
  },

	onDestroy: function(){
		this.getDeceasedClearancesStore().loadData([],false);
	},

	liveSearch : function(grid, newValue, oldValue, options){
		// console.log("Do the livesearch");
		var me = this;

		me.getMembersStore().getProxy().extraParams = {
		    livesearch: newValue,
				is_deceased: true
		};
	 
		me.getMembersStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},
	
	loadParentObjectList: function(me){
		me.getStore().getProxy().extraParams = {}
		me.getStore().getProxy().extraParams.is_deceased =  true ;
		
		me.getStore().load(); 
	},
 

  deleteObject: function() {
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getDeceasedClearancesStore();
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

			//     if (selections.length > 0) {
			// grid.enableAddButton();
			//       // grid.enableRecordButtons();
			//     } else {
			// grid.disableAddButton();
			//       // grid.disableRecordButtons();
			//     }
		
		 
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
