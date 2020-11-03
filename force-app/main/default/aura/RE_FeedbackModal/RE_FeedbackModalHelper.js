({
	submitFeedback : function(component) {
        try{ 
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.createFeedbackUpdateReferral', function(response) {
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful){
                    bSuper.showToast($A.get("$Label.c.successstatus"),'SUCCESS', $A.get("$Label.c.RE_RateThanks"));
                    $A.get('e.force:refreshView').fire();
                }else{
                    
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
                component.set("v.showFeedbackModal",false);
                
            },{
                "feedbackModalData":component.get("v.feedbackModalData"),
                "feedbackRec" : component.get("v.feedbackObject"),
                "isResourceProvided" :component.get("v.isResourceProvided")
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
       
	},
    genericToast:function(title,message,type){
        var toastEvent = $A.get("e.force:showToast"); 
        toastEvent.setParams({
            "title": title,
            "message":message,
            "type":type
        });
        toastEvent.fire();
    }
})