Ext.define('AM.controller.TransactionDatas', {
  extend: 'Ext.app.Controller',

  stores: ['TransactionDatas'],
  models: ['TransactionData'],

	startDate : null,
	endDate: null, 
	isPeriodSet : false ,
  views: [
    'operation.transactiondata.List',
    'operation.transactiondata.Form',
		'operation.transactiondatadetail.List',
		'Viewport'
  ],

  	refs: [
		{
			ref: 'list',
			selector: 'transactiondatalist'
		},
		{
			ref : 'transactiondataDetailList',
			selector : 'transactiondatadetaillist'
		},
		
		{
			ref : 'form',
			selector : 'transactiondataform'
		},
		{
			ref: 'viewport',
			selector: 'vp'
		},
	],

  init: function() {
    this.control({
      'transactiondataProcess transactiondatalist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'transactiondataProcess transactiondataform button[action=save]': {
        click: this.executeSetPeriod
      },
			'transactiondataProcess transactiondataform customcolorpicker' : {
				'colorSelected' : this.onColorPickerSelect
			},

      'transactiondataProcess transactiondatalist button[action=setPeriodObject]': {
        click: this.setPeriod
      },
      'transactiondataProcess transactiondatalist button[action=editObject]': {
        click: this.editObject
      },
      'transactiondataProcess transactiondatalist button[action=deleteObject]': {
        click: this.deleteObject
			}	,
			
			'transactiondataProcess transactiondatalist button[action=confirmObject]': {
        click: this.confirmObject
      },

			'transactiondataProcess transactiondatalist button[action=unconfirmObject]': {
        click: this.unconfirmObject
      },
	 

			'transactiondataProcess transactiondatalist textfield[name=searchField]': {
				change: this.liveSearch
			},
			'transactiondataform button[action=save]': {
        click: this.executeSetPeriod
      },

			'transactiondatalist button[action=downloadObject]': {
        click: this.downloadObject
			}	,
			'transactiondatadownloadform button[action=save]': {
        click: this.executeDownload
			}	,
		
    });
  },

	onColorPickerSelect: function(colorId, theColorPicker){
		var win = theColorPicker.up('window');
    var form = win.down('form');
		var colorField = form.getForm().findField('color'); 
		
		
		// console.log("the colorId in onColorPickerSelect:");
		// console.log( colorId);
		colorField.setValue( colorId );
		
		// console.log("The colorField.getValue()");
		// console.log( colorField.getValue() );
	
	},

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getTransactionDatasStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getTransactionDatasStore().load();
	},
 

	loadObjectList : function(me){
		var transactiondataGrid = this.getList();
		transactiondataGrid.getStore().getProxy().extraParams.start_date =  null ;
		transactiondataGrid.getStore().getProxy().extraParams.end_date =  null ;
		// console.log( "I am inside the load object list" ); 
		me.getStore().load();
	},

  setPeriod: function() {
		var view = Ext.widget('transactiondataform');
	  view.show();
  },

	executeSetPeriod: function(button){
		var win = button.up('window');
    var form = win.down('form');
		var me = this; 
 
    var values = form.getValues();

		console.log( values ) 
		console.log( values["start_date"])
		console.log( values["end_date"])
		
		var transactiondataDetailGrid = this.getTransactiondataDetailList();
		
		
		var transactiondataGrid = this.getList();
		console.log("the list");
		console.log( transactiondataGrid );
		// transactiondataDetailGrid.setTitle("Purchase Order: " + record.get('code'));
		var start_date = values["start_date"];
		var end_date = values["end_date"]
		transactiondataGrid.setTitle( "From: "  + start_date + " to " + end_date ) ;
		
		// console.log("record id: " + record.get("id"));
		
		
		if(start_date && end_date) {
			this.startDate = start_date;
			this.endDate = end_date ; 

			transactiondataGrid.enableDownloadButton();
			
			transactiondataGrid.getStore().getProxy().extraParams.start_date =  start_date ;
			transactiondataGrid.getStore().getProxy().extraParams.end_date =  end_date ;


			transactiondataGrid.getStore().load(); 

			transactiondataDetailGrid.getStore().loadData([],false);
			
			
			var transactiondataDetailGrid = this.getTransactiondataDetailList(); 
			console.log("The transactiondataDetailGrid");
			console.log( transactiondataDetailGrid );
			transactiondataDetailGrid.setObjectTitle( "" ) ;
			
			win.close();
		}
	},

  editObject: function() {
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('transactiondataform');

    view.down('form').loadRecord(record);
  },

	confirmObject: function(){
		// console.log("the startObject callback function");
		var record = this.getList().getSelectedObject();
		if(record){
			var view = Ext.widget('confirmtransactiondataform');

			view.setParentData( record );
	    view.show();
		}
		
		
		// this.reloadRecordView( record, view ) ; 
	},

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');
		var me = this; 

    var store = this.getTransactionDatasStore();
    var record = form.getRecord();
    var values = form.getValues();
 
		if( record ){
			record.set( values );
			  
			
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					store.load();
					win.close();
					// me.updateChildGrid(record );
				},
				failure : function(record,op ){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					me.reject();
				}
			});
				
			 
		}else{
			//  no record at all  => gonna create the new one 
			console.log("This is the new record")
			var me  = this; 
			var newObject = new AM.model.TransactionData( values ) ; 
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
					//  since the grid is backed by store, if store changes, it will be updated
					// console.log("create new record");
					// console.log( record )
					
					store.load();
					form.setLoading(false);
					win.close();
					// console.log("The record details");
					// console.log(record);
					me.updateChildGrid(record );
					
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

	unconfirmObject: function(){
		// console.log("the startObject callback function");
		var view = Ext.widget('unconfirmtransactiondataform');
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

    var store = this.getTransactionDatasStore();
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
	
	
	
	executeUnconfirm: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getTransactionDatasStore();
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
	


  deleteObject: function() {
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getTransactionDatasStore();
			store.remove(record);
			store.sync( );
 
			this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
	
    var grid = this.getList();

		var me= this;
		var record = this.getList().getSelectedObject(); 
		if(!record){
			return; 
		}
		
		
		me.updateChildGrid(record );
		
		 
  },

	updateChildGrid: function(record){
		console.log("Inside updateChildGrid");
		var transactiondataDetailGrid = this.getTransactiondataDetailList();
		// transactiondataDetailGrid.setTitle("Purchase Order: " + record.get('code'));
		transactiondataDetailGrid.setObjectTitle( record ) ;
		
		// console.log("record id: " + record.get("id"));
		
		transactiondataDetailGrid.getStore().getProxy().extraParams.transaction_data_id =  record.get('id') ;
		 
		transactiondataDetailGrid.getStore().load({
			params : {
				transaction_data_id : record.get('id')
			},
			callback : function(records, options, success){
				transactiondataDetailGrid.enableAddButton(); 
			}
		});
		
	},
	
	reloadRecord: function(record){
		
		var list = this.getList();
		var store = this.getList().getStore();
		var modifiedId = record.get('id');
		
		// console.log("modifiedId:  " + modifiedId);
		 
		AM.model.TransactionData.load( modifiedId , {
		    scope: list,
		    failure: function(record, operation) {
		        //do something if the load failed
		    },
		    success: function(new_record, operation) {
					// console.log("The new record");
					// 				console.log( new_record);
					recToUpdate = store.getById(modifiedId);
					recToUpdate.set(new_record.getData());
					recToUpdate.commit();
					list.getView().refreshNode(store.indexOfId(modifiedId));
		    },
		    callback: function(record, operation) {
		        //do something whether the load succeeded or failed
		    }
		});
	},
	
	downloadObject: function(){
			// var url = "transaction_datas/download_xls?start_date=" + encodeURIComponent(this.startDate) + "&" + 
			// 				"end_date=" + encodeURIComponent(this.endDate);
			// 				
			// window.open(
			// 	url, 'xls');
			
			var view = Ext.widget('transactiondatadownloadform');
		  view.show();
			
	},
	
	executeDownload: function(button){
		var win = button.up('window');
    var form = win.down('form');
 
		var me = this; 
 
    var values = form.getValues();

		console.log( values ) 
		console.log( values["start_date"])
		console.log( values["end_date"])
		
		var transactiondataDetailGrid = this.getTransactiondataDetailList();
		
		
		var transactiondataGrid = this.getList();
		
		var download_start_date = values["start_date"];
		var download_end_date = values["end_date"];
		var download_email = values["email"] ;
		
		// console.log("record id: " + record.get("id"));
		if(download_start_date && download_end_date && download_email  ){ 
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			Ext.Ajax.request({
				url: 'api/download_transaction_data',    // where you wanna post
				success : function(x, y ){
					
					// console.log(arguments.length );
					// console.log("the x value is ");
					// console.log( x ) ;
					// console.log(" the y value is " );
					// console.log( y );
					
					// console.log(x.request.responseText.reader.jsonData["message"]); // x.request.scope.reader.jsonData["message"];
					
					 
					var json = x.responseText; 
					console.log( x.request  ) ;
					
					var obj = Ext.JSON.decode(json);

					console.log(obj );
					
					if( obj.success ){
						form.setLoading(false); 
						win.close();
						
						Ext.Msg.alert('Sukses', "Laporan transaksi dari tanggal " + 
																		download_start_date + 
																		" sampai " + 
																		download_end_date + 
																		" akan dikirimkan ke " + download_email );
						
					}else{
						
						form.setLoading(false);  
						
						Ext.Msg.alert('FAIL',  obj.message );
						
					}
					
					
					
					// to  we want get the error message 
					
					
					
				},
				failure : function(x,op){
					Ext.Msg.alert('Gagal', "Gagal melakukan scheduling pembuatan laporan"  );
				},
				params: { 
					start_date: download_start_date, 
					end_date : download_end_date , 
					email : download_email 
			  }  // your json data
			});
			
			
			
			
			
			

		}
		
	},

	


});
