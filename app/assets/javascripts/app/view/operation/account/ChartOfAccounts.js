/**
 * @class SimpleTasks.view.lists.Tree
 * @extends Ext.tree.Panel
 * The task list view.  A tree that displays all of the task lists.
 */
Ext.define('AM.view.operation.account.ChartOfAccounts', {
    extend: 'Ext.tree.Panel',
    // xtype: 'listTree',
    // requires: [
    //     'Ext.grid.plugin.CellEditing',
    //     'Ext.tree.plugin.TreeViewDragDrop',
    //     'Ext.grid.column.Action'
    // ],
    // title: 'Chart of Accounts aa',
		alias : 'widget.coalist',
    store: 'Accounts',
    // hideHeaders: true,
// header : false 

    // dockedItems: [
    //     {
    //         xtype: 'toolbar',
    //         dock: 'top',
    //         items: [
    //             {
    //                 iconCls: 'tasks-new-list',
    //                 tooltip: 'New List'
    //             },
    //             {
    //                 iconCls: 'tasks-delete-list',
    //                 id: 'delete-list-btn',
    //                 tooltip: 'Delete List'
    //             },
    //             {
    //                 iconCls: 'tasks-new-folder',
    //                 tooltip: 'New Folder'
    //             },
    //             {
    //                 iconCls: 'tasks-delete-folder',
    //                 id: 'delete-folder-btn',
    //                 tooltip: 'Delete Folder'
    //             }
    //         ]
    //     }
    // ],

   

    initComponent: function() {
        var me = this;
            
				// objective 1 : to select account_case, don't call the server 
				// 
				// var storeConfig = {
				//     type: 'array',
				//     fields: [ 'company', 'price' ],
				//     data: [
				//         ['3m Co',71.72],
				//         ['Alcoa Inc',29.01],
				//         ['Boeing Co.',75.43]
				//     ]
				// };
				// 
				// 
				

				// var remoteJsonStoreCustomer = Ext.create(Ext.data.JsonStore, {
				// 	storeId : 'customer_search',
				// 	fields	: [
				// 	 				{
				// 				name : 'customer_name',
				// 				mapping : "name"
				// 			},
				// 			{
				// 				name : 'customer_bb_pin',
				// 				mapping : 'bb_pin'
				// 			},
				// 			{
				// 				name : 'customer_id',
				// 				mapping : 'id'
				// 			}
				// 	],
				// 	proxy  	: {
				// 		type : 'ajax',
				// 		url : 'api/search_customers',
				// 		reader : {
				// 			type : 'json',
				// 			root : 'records', 
				// 			totalProperty  : 'total'
				// 		}
				// 	},
				// 	autoLoad : false 
				// });
				
				
        /**
         * This Tree Panel's cell editing plugin
         * @property cellEditingPlugin
         * @type Ext.grid.plugin.CellEditing
         */

        me.columns = [
            {
                xtype: 'treecolumn',
								header : "Name",
                dataIndex: 'name',
                flex: 4,
                editor: {
                    xtype: 'textfield',
                    selectOnFocus: true,
                    allowOnlyWhitespace: false
                },
                renderer: Ext.bind(me.renderName, me)
            } ,
						// {
						//                 text: 'Amount',
						// 		header: 'Amount',
						//                 flex: 1,
						//                 dataIndex: 'amount' 
						//             },
						{
                text: 'Kode',
								header: 'Kode',
                flex: 1,
                dataIndex: 'code' 
            },

						{
                text: 'Normal Balance',
								header: 'Normal Balance',
                flex: 1,
                dataIndex: 'normal_balance_text' 
            },
						// {
						//                 text: 'Contra Account',
						// 		header: 'Contra Account',
						//                 flex: 1,
						//                 dataIndex: 'contra_account_text' 
						//             }
        ];
        
				me.addObjectButton = new Ext.Button({
					text: 'Add Account',
					action: 'addObject',
					disabled: true
				});

				me.editObjectButton = new Ext.Button({
					text: 'Edit Account',
					action: 'editObject',
					disabled: true
				});

				me.deleteObjectButton = new Ext.Button({
					text: 'Delete Account',
					action: 'deleteObject',
					disabled: true
				});

			 
				
				me.tbar = [me.addObjectButton, me.editObjectButton, me.deleteObjectButton  ];
				
				
        me.callParent(arguments);

        // me.addEvents(
        //     /**
        //      * @event deleteclick
        //      * Fires when the delete icon is clicked
        //      * @param {Ext.grid.View} gridView
        //      * @param {Number} rowIndex
        //      * @param {Number} colIndex
        //      * @param {Ext.grid.column.Action} column
        //      * @param {EventObject} e
        //      */
        //     'deleteclick',
        // 
        //     /**
        //      * @event taskdrop
        //      * Fires when a task record is dropped on this grid
        //      * @param {SimpleTasks.model.Task} task       The task record
        //      * @param {SimpleTasks.model.List} list       The list that the task was dropped on
        //      */
        //     'taskdrop',
        // 
        //     /**
        //      * @event listdrop
        //      * Fires when a list record is dropped on this grid
        //      * @param {SimpleTasks.model.List} list         The list that was dropped
        //      * @param {SimpleTasks.model.List} overList     The list that the list was dropped on
        //      * @param {String} position               `"before"` or `"after"` depending on whether the mouse is above or below the midline of the node.
        //      */
        //     'listdrop'
        // );

        // me.on('beforeedit', me.handleBeforeEdit, me);
        // me.relayEvents(me.getView(), ['taskdrop', 'listdrop'])

    },

    /**
     * Handles a click on a delete icon
     * @private
     * @param {Ext.tree.View} treeView
     * @param {Number} rowIndex
     * @param {Number} colIndex
     * @param {Ext.grid.column.Action} column
     * @param {EventObject} e
     */
    handleDeleteClick: function(gridView, rowIndex, colIndex, column, e) {
        // Fire a "deleteclick" event with all the same args as this handler
        this.fireEvent('deleteclick', gridView, rowIndex, colIndex, column, e);
    },

    /**
     * Handles this grid's "beforeedit" event (relayed from the CellEditing plugin).
     * Prevents editing of "All Lists" root by returning false if the record has an id of -1
     * @private
     * @param {Ext.grid.plugin.CellEditing} editingPlugin       The cell editing plugin
     * @param {Object} e                                        an edit event object
     */
    handleBeforeEdit: function(editingPlugin, e) {
        return e.record.get('id') !== -1;
    },

    /**
     * Renderer for the name field.
     * Adds the task count after the list name.
     * @private
     * @param {String} value
     * @param {Object} metaData
     * @param {SimpleTasks.model.List} list
     * @param {Number} rowIndex
     * @param {Number} colIndex
     * @param {SimpleTasks.store.Lists} store
     * @param {Ext.grid.View} view
     */
    renderName: function(value, metaData, list, rowIndex, colIndex, store, view) {
        // var tasksStore = Ext.StoreMgr.lookup('Tasks'),
        //     count = 0;
        // 
        // (function countTasks(list) {
        //     count += tasksStore.queryBy(function(task, id) {
        //         // only show count for tasks that are not done
        //         return task.get('list_id') === list.get('id') && task.get('done') === false;
        //     }).getCount();
        // 
        //     list.eachChild(function(child) {
        //         countTasks(child);
        //     });
        // })(list);

        // return value + ' (' + count + ')';
				return value ;
    },

    /**
     * Triggers the list tree to refresh its view.  This is necessary in two scenarios:
     * 1) Since the lists and tasks are loaded asyncrounously, The Lists store may have finished
     *    loading before the tasks store.  In this case, the tasks data would not be available so all
     *    of the task counts would be rendered as (0).
     * 2) When a task is dragged and dropped onto a list, or when a list is deleted the task count won't automatially be updated
     *    because none of the data in the lists store actually changed (the renderer gets the count
     *    from the tasks store).
     *    
     * In both situations refreshing the lists view we ensure that the task counts are accurate.
     */
    refreshView: function() {
        // refresh the data in the view.  This will trigger the column renderers to run, making sure the task counts are up to date.
        this.getView().refresh();
    },

		enableRecordButtons: function(record) {
			// console.log("The value: ");
			// console.log( AM.view.Constants.account_case.group);
			
			if( record.get('account_case') === AM.view.Constants.account_case.group){
				this.addObjectButton.enable();
			}else{
				this.addObjectButton.disable();
			}
			
			
			this.editObjectButton.enable();
			this.deleteObjectButton.enable(); 
		},
		
		disableRecordButtons: function() {
			this.addObjectButton.disable();
			this.editObjectButton.disable();
			this.deleteObjectButton.disable();
		}

		



});