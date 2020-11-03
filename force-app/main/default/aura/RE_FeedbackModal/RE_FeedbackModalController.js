({
    /*JAWS Fix : To move focus on Dialog Box upon loading */
	doInit : function() {
        setTimeout(function(){
           document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },500);
	},    
	closeFeedbackModal : function(component,helper) {
        component.set("v.showFeedbackModal",false);
        var conditionalMsg = component.get("v.feedbackConditionalMsg");
        if(conditionalMsg === 'markascomplete'){
            helper.genericToast('Error',$A.get('$Label.c.must_rate_resource'),'error');
        }
        else{
            helper.genericToast('Error',$A.get('$Label.c.rate_resource'),'error');
        }
    },
    handleSubmit:function(component) {
        component.set("v.showFeedbackModal",true);
    },
    moveFocusToTop: function(component, event) { // JAWS Issue Fix
        if(event.keyCode === 9) {
            setTimeout(function(){
                document.getElementsByClassName("modal-lg-heading")[0].focus(); 
            },10)
        }
    },
    moveToBottom: function(component, event) { // JAWS Issue Fix
        if(event.keyCode === 16) {
            if(event.shiftKey) {
                setTimeout(function(){
             		document.getElementsByClassName("testclose").focus();
                },100)
            }
        }
    },
    handleFeedback:function(component, event) {
        var button = event.getSource();
        var id = button.getLocalId();
        if(id ==="yes"){
            component.set("v.isYesClicked",true);
            component.set("v.isNoClicked",false);  
            component.set("v.feedbackObject.Rating__c",1);
        }
        else{
            component.set("v.isYesClicked",false);
            component.set("v.isNoClicked",true);  
            component.set("v.feedbackObject.Rating__c",0);
        }
    },
    handleRecommend:function(component, event) {
        var value=event.getSource().get('v.value');
        if(value ==="True"){
            component.set("v.bisRecommendVisible",true);
        }
        else{
            component.set("v.bisRecommendVisible",false);
        }
    },
    submitFeedback:function(component,event,helper){
        if(component.get("v.bisRecommendVisible")===false){
            if(component.get("v.isResourceProvided") === undefined && component.get("v.isRadioSectionVisible") === true){ 
                helper.genericToast('Error',$A.get('$Label.c.rate_resource'),'error'); 
            }
            else{
                helper.submitFeedback(component,event);
            }
        }
        else if(component.get("v.feedbackObject.Rating__c") === undefined){
            helper.genericToast('Error',$A.get('$Label.c.rate_resource'),'error'); 
        }
        else{
            helper.submitFeedback(component,event);       
        }      
    }
    
})