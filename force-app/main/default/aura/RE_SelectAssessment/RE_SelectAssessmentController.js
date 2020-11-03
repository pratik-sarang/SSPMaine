({	
    doInit : function(component,event,helper) {
        
        
        helper.getAssessment(component,event,helper)
    },
    selectAssessment:function(component,event,helper){
        var selectedAssessmentIndex=event.getSource().get("v.value");
        component.set("v.selectedRadioAssessmentObj",component.get("v.lstAssessment")[selectedAssessmentIndex]);
        helper.startAssessementHelper(component,event);
    },
    backToOneView:function(component){
        component.set("v.bisAssesmentOpen",false);
        component.set('v.showClientDetail',true);
        
    },
     closehandler: function(component, event) {
        if(event.getParam("sObject") ==='Assessment__c'){
           component.set("v.bshowassessmentques",false);
        }
        
        var reloadtable = component.get('c.doInit');
        $A.enqueueAction(reloadtable);
    },
    onReset : function(component,event){
       
        
        var params = event.getParam('arguments');	
        if (params) {
                    var reloadtable = component.get('c.doInit');
        $A.enqueueAction(reloadtable);
        }
        
    },
})