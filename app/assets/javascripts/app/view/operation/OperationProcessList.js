Ext.define('AM.view.operation.OperationProcessList', {
    extend: 'Ext.tree.Panel',
    alias: 'widget.operationProcessList',

    
    // title: 'Process List',
    rootVisible: false,
		cls: 'examples-list',
    lines: false,
    useArrows: true,

		store: 'Navigations'
});
