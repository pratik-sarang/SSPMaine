({
	 handleSort : function(component,event,helper){
        var sortBy = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        helper.sortData(component,sortBy,sortDirection);
    },
    handleRowClick:function (cmp, event, helper) {
        if(cmp.get("v.callFunction") === "ClientNotes"){
             helper.showNotesView(cmp,event);
        }
        if(cmp.get("v.callFunction") === "ViewAssessment"){
            var row = event.getParam('row'); 
            var assessmentId=window.btoa(row.assessmentId);
            window.open('assessment-results?Id='+assessmentId,'_self');
        }
    }
})