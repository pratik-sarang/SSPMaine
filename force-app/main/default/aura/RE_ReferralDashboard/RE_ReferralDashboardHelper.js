({
    onLoadHelper : function(component) {
        var bSuper = component.find("bSuper");
        try{
            component.set('v.isSpinnerActive',true);
            this.createColumnData(component);
            bSuper.callServer(component, 'c.getStatisticsData', function(response){
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful){  
                    var objectData = response.objectData.statisticsData;

                component.set("v.mostReferredByOrg",objectData.mostReferredByOrg);
                component.set("v.mostReferredToOrg",objectData.mostReferredToOrg);
                    if(objectData.orgRating === 0){
                        component.set("v.orgRating",'NA');
                    }else{
                component.set("v.orgRating",objectData.orgRating);
                    }
                component.set("v.totalClientsServed",objectData.totalClientsServed[0].expr0);
                component.set("v.avgDaysToClose",objectData.avgDaysToClose);
                component.set("v.referralsOpen",objectData.referralsOpen[0].expr0);
                    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
                    component.set("v.referralsReceived",objectData.referralsReceived[0].expr1);
                component.set("v.referralsClosed",objectData.referralsClosed[0].expr0);
                component.set("v.referralsMade",objectData.referralsMade[0].expr0);
                }
                
            },null,false);
        }catch(e){
            bSuper.consoleLog(e.stack, true);
            }
            
    },
    //Venkat: 03/04/2020: Spanish Translation
    createColumnData:function(component){
        var referredByColumnData=[];
        referredByColumnData.push({ label: $A.get("$Label.c.organization"),fieldName: 'Name', type: 'text'},
                          			{ label: $A.get("$Label.c.RE_Referrals"),fieldName: 'expr0', type: 'number'})
        component.set("v.referredByAndToHeaders",referredByColumnData);
    }
})