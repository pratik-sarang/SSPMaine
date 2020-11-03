({
	doInit : function(component, event,helper) {
        helper.getReportsHelper(component,event);
	},
    onSelectReport:function(component,event,helper){
        var reportId=component.find('selectReport').get('v.value')
        var url='report/'+reportId+'?isReport=true';
        helper.gotoURL(component,event, url);
    }
    
})