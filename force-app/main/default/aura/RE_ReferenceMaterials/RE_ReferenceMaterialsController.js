({
    
    openModel: function(component) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    openDoc: function() {
        var profUrl = $A.get('$Resource.RE_RefferalDoc');
       	window.open(profUrl);
    },
    //Open File onclick event  
    OpenFile :function(component,event){  
        var rec_id = event.currentTarget.id;  
        $A.get('e.lightning:openFiles').fire({ //Lightning Openfiles event  
            recordIds: [rec_id] //file id  
        });  
    },
    
    getSelected : function(component,event,helper){
        // display modle and set seletedDocumentId attribute with selected record Id   
        //component.set("v.hasModalOpen" , true);
        component.set("v.selectedDocumentId" , event.currentTarget.id); 
        helper.OpenFile(component,event);
        //openDoc();
    },
    closeModel: function(component) {
        // for Close Model, set the "hasModalOpen" attribute to "FALSE" 
        component.set("v.isOpen", false); 
        component.set("v.hasModalOpen", false);
        component.set("v.selectedDocumentId" , null); 
    },
    openFileCustom : function(component, event){
        var recId = event.currentTarget.id;
        var openFileEvt = $A.get("e.forceChatter:customOpenFile");
        openFileEvt.fire({
           "recordId": recId
        });
    }
})