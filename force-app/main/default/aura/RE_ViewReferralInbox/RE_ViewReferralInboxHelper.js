({
    doInitHandler : function(component){
        try{
            var optionSelected=window.location.pathname.split('/s/')[1].replace(/-/g, ' ');
            if(optionSelected==='referral inbox' || optionSelected===""){
                component.set('v.isReferralInbox',true);
            }else{
                component.set('v.isReferralInbox',false);
            }
            this.createColumnData(component);
            /********** Fixed for Performance Issue: **********/
            //RE_Release 1.1 – Perf - Prashant – Commented as part of perf issue - no longer needed since we have page variations
            //show spinner when request sent
        /*    component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getLoggedInUserRole', function(response){
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var bIsAdminStaff = response.objectData.bIsAdminStaff;
                    component.set("v.bIsAdminStaff",bIsAdminStaff);
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast('ERROR','Error',errMsg);
                }
            },null,false);  */
        }
        catch(e){
            bSuper.consoleLog(e.stack, true);
        }
    },
    createColumnData:function(component){
        var columnData=[];
        //Venkat: 03/04/2020: Spanish Translation
        columnData.push({ label: $A.get("$Label.c.RE_ID"), fieldName: 'Name', type: 'text',sortable : true},
                        { label: $A.get("$Label.c.firstname"), fieldName: 'Contacts__c', type: 'text',sortable : true},
                        { label: $A.get("$Label.c.lastname"), fieldName: 'CreatedbyId', type: 'text',sortable : true},
                        { label: $A.get("$Label.c.referraldate"), fieldName: 'CreatedDate', type: 'date-local',sortable : true,typeAttributes: {day: 'numeric', month: 'numeric',year: 'numeric'}},
                        { label: $A.get("$Label.c.RE_Created"), fieldName: 'DaysSinceOpened__c', type: 'text',sortable : true}, 
                        { label: $A.get("$Label.c.ResourceRequested"), fieldName: 'Resource__c', type: 'text',sortable : true},
                        { label: $A.get("$Label.c.RE_Location"), fieldName: 'location__c', type: 'text',sortable : true},
                        { label: $A.get("$Label.c.RE_Status"), fieldName: 'Status__c', type: 'text',sortable : true})
        
        if(component.get('v.isReferralInbox')){
            columnData.push({ label: $A.get("$Label.c.RE_EditLabel"), type:'action', typeAttributes:{rowActions: [
                            								{label:$A.get("$Label.c.RE_EditLabel"), name:'edit'}
                                                            ]}});
        }
        else{
            columnData.push({ label: $A.get("$Label.c.RE_View"), type:'action', typeAttributes:{rowActions: [
                                                            {label:$A.get("$Label.c.RE_View"), name:'view'}
                                                            ]}});
        }
        component.set("v.mycolumns",columnData);
    }
})