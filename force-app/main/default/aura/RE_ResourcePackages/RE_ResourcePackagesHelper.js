({
    fireCarouselEvent : function(component, event, showCarousel) {
        var carouselEvent = $A.get("e.c:RE_ShowHideCarousel");
        carouselEvent.setParams({ "showCarousel" : showCarousel });
        carouselEvent.fire();
    },
    getGuestAssessment : function(component){
        try{ 
            
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.fetchGuestAssessmentRecords', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do                               
                if(response.isSuccessful){
                   
                    var assesmentLst = response.objectData.assessmentRecords;
                    var assessmentId = window.btoa(assesmentLst[0].Id);
                    var templateName = window.btoa(assesmentLst[0].AssessmentTitle__c);

                    
                    var url='guest-assessment?Id='+assessmentId+'&tempName='+templateName;
                    window.open(url,'_self'); 
                }else{                    
                    bSuper.showToast('Error', 'Error', 'Component failure , please contact your adminstrator');
                }
                
            },null,false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }         
    }
    
})