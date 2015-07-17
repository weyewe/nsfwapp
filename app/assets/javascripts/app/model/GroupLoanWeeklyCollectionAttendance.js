Ext.define('AM.model.GroupLoanWeeklyCollectionAttendance', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'group_loan_weekly_collection_id', type: 'int' },
		{ name: 'group_loan_membership_id', type: 'int' } ,
		{ name: 'member_name', type: 'string' }   ,
		{ name: 'group_loan_weekly_collection_week_number', type: 'string' }  ,  
		{ name: 'attendance_status', type: 'string' }  ,  
		{ name: 'payment_status', type: 'string' }   
  	],

	 


   
  	idProperty: 'id' ,

		proxy: {
			url: 'api/group_loan_weekly_collection_attendances',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'group_loan_weekly_collection_attendances',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { group_loan_weekly_collection_attendance : record.data };
				}
			}
		}
	
  
});
