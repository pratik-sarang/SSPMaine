({ 
    init: function (cmp, event, helper) {
        cmp.set('v.mydatanotes',null);
        cmp.set('v.pageNumber',1);
        cmp.set("v.NotesTitle",'');
        cmp.set('v.mycolumns', cmp.get("v.mycolumns"));
        var obj = cmp.get('v.sObject');
        if(obj === 'ContentNote')
            helper.getNotes(cmp,helper);    
        
    },
    hideEditModal:function (cmp ) {
        cmp.set("v.showEditModal",false);
    },
    moveFocusToTop: function(event) {//JAWS FIXES
        if(event.keyCode === 9) {
            setTimeout(function(){
               document.getElementsByClassName("modal-lg-heading")[0].focus(); 
            },10);
        }
    },
    showEditModal:function (cmp) {
        cmp.set("v.showEditModal",true);
        setTimeout(function(){
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
         },1000);
    },
    onSave:function (cmp, event, helper) {

        
       // if(title ){
       if(cmp.get("v.NotesTitle") && !$A.util.isEmpty(cmp.get("v.NotesTitle").trim()) && cmp.get("v.NotesDescription") && !$A.util.isEmpty(cmp.get("v.NotesDescription").trim())){
        helper.createNotes(cmp,event,helper);
        cmp.set('v.mydatanotes',null);
        cmp.set('v.pageNumber',1);
        helper.getNotes(cmp,helper); 
        cmp.set("v.showEditModal",false);
          cmp.set("v.NotesTitle",'');
            cmp.set("v.NotesDescription",'');
          
        }else{
            var errMsg = $A.get("$Label.c.mandatoryfieldserror") ;
            helper.showToast(cmp, event, helper, 'Error', errMsg);
            
        }
    },
    handleRowClick:function (cmp, event) {
        
        var obj = cmp.get('v.sObject');
        //var action = event.getParam('action');
       // var row = event.getParam('row').Id;
       if(obj === 'ContentNote'){
            $A.createComponent(
                "c:RE_NotesDetails",{ "recId" : event.getParam('row'),"isReferralInbox":cmp.get("v.isReferralInbox")},
                function(newcomponent){
                    if (cmp.isValid()) {
                        var body = cmp.get("v.body");
                        body.push(newcomponent);
                        cmp.set("v.body", body);             
                    }
                }            
            );
        }
    },
     handleSort : function(component,event,helper){
        var sortBy = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        helper.sortData(component,sortBy,sortDirection);
    },
    handleNext : function(component, event, helper) { 
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber+1);
      //  helper.getData(component);
        helper.getNotes(component,helper);
    },     
    handlePrev : function(component, event, helper) {        
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber-1);
        helper.getNotes(component,helper);
    },
    handlerefresh:  function(component,event,helper){
        //On addition of new note refresh note table
        component.set('v.mydatanotes',null);
        component.set('v.pageNumber',1);
        helper.getNotes(component,helper);
    }
})