Ext.define('AM.store.Accounts', {
    extend: 'Ext.data.TreeStore',
    model: 'AM.model.Account',

		autoLoad : false, 
		autoSync: false,
    // root: {
    //     expanded: true,
    //     id: -1,
    //     name: 'Accounts'
    // }

		root: {
		        expanded: true,
		        // id: -1,
		        name: 'Accounts'
		    }
});
