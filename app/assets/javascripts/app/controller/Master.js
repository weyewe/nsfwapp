Ext.define("AM.controller.Master", {
	extend : "AM.controller.BaseTreeBuilder",
	views : [
		"master.MasterProcessList",
		'MasterProcessPanel',
		'Viewport'
	],

	 
	
	refs: [
		{
			ref: 'masterProcessPanel',
			selector: 'masterProcessPanel'
		} ,
		{
			ref: 'masterProcessList',
			selector: 'masterProcessList'
		}  
	],
	

	 
	init : function( application ) {
		var me = this; 
		 
		me.control({
			"masterProcessPanel" : {
				activate : this.onActiveProtectedContent,
				deactivate : this.onDeactivated
			} 
			
		});
		
	},
	
	onDeactivated: function(){
		// console.log("Master process panel is deactivated");
		var worksheetPanel = Ext.ComponentQuery.query("masterProcessPanel #worksheetPanel")[0];
		worksheetPanel.setTitle(false);
		// worksheetPanel.setHeader(false);
		worksheetPanel.removeAll();		 
		var defaultWorksheet = Ext.create( "AM.view.master.Default");
		worksheetPanel.add(defaultWorksheet); 
	},
	
	 

	setupFolder : {
		text 			: "Setup", 
		viewClass : '',
		iconCls		: 'text-folder', 
    expanded	: true,
		children 	: [
        
      { 
          text:'Member', 
          viewClass:'AM.view.master.Member', 
          leaf:true, 
          iconCls:'text',
 					conditions : [
						{
							controller : "members",
							action  : 'index'
						}
					]
      },

      { 
          text:'Branch', 
          viewClass:'AM.view.master.Branch', 
          leaf:true, 
          iconCls:'text',
 					conditions : [
						{
							controller : "branches",
							action  : 'index'
						}
					]
      },
      { 
          text:'Employee', 
          viewClass:'AM.view.master.Employee', 
          leaf:true, 
          iconCls:'text',
 					conditions : [
						{
							controller : "employees",
							action  : 'index'
						}
					]
      },


      { 
				text:'GroupLoan Product', 
				viewClass:'AM.view.master.GroupLoanProduct', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'group_loan_products',
						action : 'index'
					}
				]
			}, 
			
			{ 
				text:'User', 
				viewClass:'AM.view.master.User', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'users',
						action : 'index'
					}
				]
			},
    ]
	},
	
	inventoryFolder : {
		text:'Master Data', 
    viewClass:'Will', 
    iconCls:'text-folder', 
    expanded: true,
		children : [
	
			{ 
				text:'User', 
				viewClass:'AM.view.master.User', 
				leaf:true, 
				iconCls:'text',
				conditions : [
					{
						controller : 'users',
						action : 'index'
					}
				]
	     },
			{ 
				text:'Category', 
				viewClass:'AM.view.master.Category', 
				leaf:true, 
				iconCls:'text',
				conditions : [
					{
						controller : 'categories',
						action : 'category'
					}
				]
	     }
		]
	},
	
	reportFolder : {
		text:'Employee Report', 
    viewClass:'Will', 
    iconCls:'text-folder', 
    expanded: true,
		children : [
	 
			{ 
	        text:'By Project', 
	        viewClass:'AM.view.master.report.employee.WorkProject', 
	        leaf:true, 
	        iconCls:'text' ,
					conditions : [
						{
							controller : 'works',
							action : 'reports'
						}
					
					]
	    },
			{ 
          text:'By Category', 
          viewClass:'AM.view.master.report.employee.WorkCategory', 
          leaf:true, 
          iconCls:'text' ,
					conditions : [
						{
							controller : 'works',
							action : 'reports'
						}
						
					]
      },
			
		]
		
	},
	
	projectReportFolder : {
		text:'Project Report', 
    viewClass:'Will', 
    iconCls:'text-folder', 
    expanded: true,
		children : [
	 
	 
			{ 
          text:'By Category', 
          viewClass:'AM.view.master.report.project.WorkCategory', 
          leaf:true, 
          iconCls:'text' ,
					conditions : [
						{
							controller : 'works',
							action : 'reports'
						}
						
					]
      },
			
		]
		
	},
	 
	onActiveProtectedContent: function( panel, options) {
		var me  = this; 
		var currentUser = Ext.decode( localStorage.getItem('currentUser'));
		var email = currentUser['email'];
		
		me.folderList = [
			this.setupFolder,
			// this.inventoryFolder,
			// this.reportFolder,
			// this.projectReportFolder
		];
		
		var processList = panel.down('masterProcessList');
		processList.setLoading(true);
	
		var treeStore = processList.getStore();
		treeStore.removeAll(); 
		
		treeStore.setRootNode( this.buildNavigation(currentUser) );
		processList.setLoading(false);
	},
});