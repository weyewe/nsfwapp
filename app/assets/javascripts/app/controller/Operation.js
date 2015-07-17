Ext.define("AM.controller.Operation", {
	extend : "AM.controller.BaseTreeBuilder",
	views : [
		"operation.OperationProcessList",
		'OperationProcessPanel',
		'Viewport'
	],

	 
	
	refs: [
		{
			ref: 'operationProcessPanel',
			selector: 'operationProcessPanel'
		} ,
		{
			ref: 'operationProcessList',
			selector: 'operationProcessList'
		}  
	],
	

	 
	init : function( application ) {
		var me = this; 
		 
		me.control({
			"operationProcessPanel" : {
				activate : this.onActiveProtectedContent,
				deactivate : this.onDeactivated
			} 
			
		});
		
	},
	
	onDeactivated: function(){
		// console.log("Operation process panel is deactivated");
		var worksheetPanel = Ext.ComponentQuery.query("operationProcessPanel #operationWorksheetPanel")[0];
		worksheetPanel.setTitle(false);
		// worksheetPanel.setHeader(false);
		worksheetPanel.removeAll();		 
		var defaultWorksheet = Ext.create( "AM.view.operation.Default");
		worksheetPanel.add(defaultWorksheet); 
	},
	
	 

	setupFolder : {
		text 			: "GroupLoan", 
		viewClass : '',
		iconCls		: 'text-folder', 
    expanded	: true,
		children 	: [

      { 
          text:'Management', 
          viewClass:'AM.view.operation.GroupLoan', 
          leaf:true, 
          iconCls:'text',
 					conditions : [
						{
							controller : "group_loans",
							action  : 'index'
						}
					]
      },
      { 
				text:'Membership', 
				viewClass:'AM.view.operation.GroupLoanMembership', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'group_loan_memberships',
						action : 'index'
					}
				]
			}, 
			{ 
				text:'Collection', 
				viewClass:'AM.view.operation.GroupLoanWeeklyCollection', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'group_loan_weekly_collections',
						action : 'index'
					}
				]
			},
			{ 
				text:'Uncollectible', 
				viewClass:'AM.view.operation.GroupLoanWeeklyUncollectible', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'group_loan_weekly_uncollectibles',
						action : 'index'
					}
				]
			}, 
			{ 
				text:'Premature Clearance', 
				viewClass:'AM.view.operation.GroupLoanPrematureClearancePayment', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'group_loan_premature_clearance_payments',
						action : 'index'
					}
				]
			},

	      { 
	          text:'Loan History', 
	          viewClass:'AM.view.operation.LoanTrail', 
	          leaf:true, 
	          iconCls:'text',
	 					conditions : [
							{
								controller : "group_loans",
								action  : 'index'
							}
						]
	      },
    ]
	}, 
	
	deceasedFolder : {
		text 			: "Meninggal", 
		viewClass : '',
		iconCls		: 'text-folder', 
    expanded	: true,
		children 	: [
        
      { 
          text:'Insurance Claim', 
          viewClass:'AM.view.operation.DeceasedClearance', 
          leaf:true, 
          iconCls:'text',
 					conditions : [
						{
							controller : "deceased_clearances",
							action  : 'index'
						}
					]
      } 
    ]
	},
	
	runAwayFolder : {
		text 			: "Kabur", 
		viewClass : '',
		iconCls		: 'text-folder', 
    expanded	: true,
		children 	: [
        
      { 
          text:'Clearance', 
          viewClass:'AM.view.operation.GroupLoanRunAwayReceivable', 
          leaf:true, 
          iconCls:'text',
 					conditions : [
						{
							controller : "group_loan_run_away_receivables",
							action  : 'index'
						}
					]
      } 
    ]
	},
	
	savingsFolder : {
		text 			: "Tabungan", 
		viewClass : '',
		iconCls		: 'text-folder', 
    expanded	: true,
		children 	: [
        
      { 
          text:'Savings', 
          viewClass:'AM.view.operation.SavingsEntry', 
          leaf:true, 
          iconCls:'text',
 					conditions : [
						{
							controller : "savings_entries",
							action  : 'index'
						}
					]
      } 
    ]
	},
	
	accountingFolder : {
		text 			: "Akunting", 
		viewClass : '',
		iconCls		: 'text-folder', 
    expanded	: true,
		children 	: [
        
			{ 
	        text:'CoA', 
	        viewClass:'AM.view.operation.Account', 
	        leaf:true, 
	        iconCls:'text',
					conditions : [
						{
							controller : "accounts",
							action  : 'index'
						}
					]
	    }, 
      { 
          text:'Memorial', 
          viewClass:'AM.view.operation.Memorial', 
          leaf:true, 
          iconCls:'text',
 					conditions : [
						{
							controller : "memorials",
							action  : 'index'
						}
					]
      },
			{ 
          text:'TransactionData', 
          viewClass:'AM.view.operation.TransactionData', 
          leaf:true, 
          iconCls:'text',
 					conditions : [
						{
							controller : "transaction_datas",
							action  : 'index'
						}
					]
      } 
    ]
	},
	
	onActiveProtectedContent: function( panel, options) {
		var me  = this; 
		var currentUser = Ext.decode( localStorage.getItem('currentUser'));
		var email = currentUser['email'];
		
		me.folderList = [
			this.setupFolder ,
			this.deceasedFolder,
			this.runAwayFolder,
			this.savingsFolder,
			this.accountingFolder
		];
		
		var processList = panel.down('operationProcessList');
		processList.setLoading(true);
	
		var treeStore = processList.getStore();
		treeStore.removeAll(); 
		
		treeStore.setRootNode( this.buildNavigation(currentUser) );
		processList.setLoading(false);
	},
});