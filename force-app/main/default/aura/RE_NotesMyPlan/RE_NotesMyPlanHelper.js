({
    addNoteHandler : function(component, event, helper) {
        var notedata = component.find("notebody").get("v.value");
        if(notedata != null && notedata != ""){
            component.set('v.bIsButtonClicked',false);
        }else{
           component.set("v.bIsButtonClicked", true); 
        }
        var referralId = event.getSource().get("v.value");
        var action = component.get("c.createNote");
        action.setParams({ 
            "title" : notedata, 
            "description" : notedata,
            "recid": referralId,
            "isPublic" : true
        });
        action.setCallback(this, function(responsedata) {
            var state = responsedata.getState();
            if (state === "SUCCESS") {
                helper.displayToastMessage(component, $A.get("$Label.c.successstatus"), $A.get("$Label.c.notessuccessmessage"), 'SUCCESS');
                component.find("notebody").set("v.value", "");
                referralId = event.getSource().get("v.value");
                action = component.get("c.getReferralNotes");
                action.setParams({
                    "recid":referralId, 
                    "pageSize":"1000", 
                    "pageNumber" : "1"
                });
                action.setCallback(this, function(response) {
                    state = response.getState();
                    if (state === 'SUCCESS') {
                        var result = response.getReturnValue();
                        var listNotes = result.objectData.records;
                        if(listNotes){
                            for(var i=0;i<listNotes.length;i+=1){
                                if(listNotes[i].Description.indexOf("\\&#39;") > -1){
                                    listNotes[i].Description = listNotes[i].Description.split("\\&#39;").join("\'");
                                }
                                if(listNotes[i].Description.indexOf("\\") > -1){
                                    listNotes[i].Description = listNotes[i].Description.split("\\").join("");
                                }
                                if(listNotes[i].Description.indexOf("\&quot;") > -1){
                                    listNotes[i].Description = listNotes[i].Description.split("\&quot;").join("\"");
                                }
                            }
                        }
                        component.set("v.listNoteWrapper.lstNotes", listNotes);
                        component.set("v.bIsButtonClicked", false);
                    }
                });
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(action);
    },
    /* display toast messages */
    displayToastMessage : function(component, title, msg, variant) {
        component.find('notifLib').showToast({
            "title": title,
            "message": msg,
            "variant": variant
        });
    },
})