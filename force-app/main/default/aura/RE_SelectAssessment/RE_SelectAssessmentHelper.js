({
    getAssessment:function(component){
        try{
            var bSuper = component.find("bSuper");
            bSuper.callServer(component, 'c.fetchrec', function(response) {
                if(response.isSuccessful){
                    var objectData = response.objectData.assessmentRecords;
                    component.set("v.lstAssessment",objectData);
                    component.set("v.bShowtemplate",true);
                    
                }
                else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            });
        }
        catch (e) { 
            bSuper.consoleLog(e.stack, true);
        }
    },
    startAssessementHelper:function(component){
        if(component.get("v.bIsCitizen") === true){
            //set the values here 
            var clientId=component.get("v.sClientId") ? window.atob(component.get("v.sClientId")) : '';
            component.set("v.clientId",clientId); 
            component.set("v.tempname",component.get("v.selectedRadioAssessmentObj").AssessmentTitle__c);
            component.set("v.assessmentId",component.get("v.selectedRadioAssessmentObj").Id);  
            component.set("v.bshowassessmentques",true); 
            component.set("v.bShowtemplate",false); 
            
        }else{
            var assessmentId=window.btoa(component.get("v.selectedRadioAssessmentObj").Id);
            var clientId=window.btoa(component.get("v.sClientId"));
            var templateName=window.btoa(component.get("v.selectedRadioAssessmentObj").AssessmentTitle__c);
            var clientName=window.btoa(component.get("v.sClientName"));
            var url='assessment?Id='+assessmentId+'&user='+clientId+'&tempName='+templateName+'&cName='+clientName;
            window.open(url,'_self');
            
            
        }
        
    }

})