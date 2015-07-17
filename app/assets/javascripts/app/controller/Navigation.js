Ext.define("AM.controller.Navigation", {
	extend : "Ext.app.Controller",
	views : [
		"Content" 
	],
	
 
	
	refs: [
		{
			ref: 'viewport',
			selector: 'vp'
		} ,
		{
			ref : 'content',
			selector : 'content'
		} 
	],
	
	  
	
	 
	
	init : function( application ) {
		var me = this; 
		
		me.control({  
			'navigation	button[action=switchPersonalReport], navigation button[action=switchOperation], navigation button[action=switchMaster]' : {
				click : me.switchScreen
			},
			
 
		});
	},
	 

	switchScreen: function(btn){ 
		var me = this; 
		var activeItem = AM.view.Constants[ btn.action ] ; 
		
		me.getContent().layout.setActiveItem( AM.view.Constants[ btn.action ] );
	}  
});