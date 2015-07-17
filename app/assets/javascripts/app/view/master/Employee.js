Ext.define('AM.view.master.Employee', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.employeeProcess',
	 
		
		items : [
			{
				xtype : 'employeelist' ,
				flex : 1 
			} 
		]
});