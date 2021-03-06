({
	checkEditPermission : function(component) {
		var noteId=component.get("v.noteDetails.NoteId");
        try{
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.checkNoteEditPermission', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful){
                    component.set("v.isEditable",response.objectData.isEditable);
                }else{
                    component.set("v.isEditable",false);
                }
                
            },{
                strNoteId:noteId
            },false);
        }catch (e) {
        }
	},
	saveNote : function(component,event,helper) {
		var noteId=component.get("v.noteDetails.NoteId");
        try{
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.updateNote', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                component.set("v.isEditable",true);
                if(response.isSuccessful){
                    component.set("v.showEditModal",false);
                    var cmpEvent = component.getEvent("refreshevt");
                    cmpEvent.fire();
                    var successMsg = $A.get("$Label.c.NoteUpdate");
                    this.showToast(component, event, helper, 'Success', successMsg);
                }else{
                    component.set("v.showEditModal",false);
                    var errMsg = $A.get("$Label.c.servererror");
                    this.showToast(component, event, helper, 'Error', errMsg);
                }
                
            },{
                strNoteId:noteId,
                strTitle:component.get("v.noteDetails.Title"),
                strDescription: component.get("v.noteDetails.Description")
            },false);
        }catch (e) {
        }
	},
    showToast : function(component, event, helper, variant, msg){
        if(variant === 'Success'){
            component.find('notifLib').showToast({
                "title": $A.get("$Label.c.successstatus"),
                "message": msg,
                "variant": "success"
            });
        }else if(variant === 'Error'){
            component.find('notifLib').showToast({
                "title": $A.get("$Label.c.errorstatus"),
                "message": msg,
                "variant": "error"
            });
        }
    },
})